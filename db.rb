require 'datamapper'
require 'string-ext'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

class Thing
  include DataMapper::Resource  
  property :id,                    Serial
  property :canonical_text,        String, :length=> 1..1024
  property :type,                  String
  property :pk,                    Integer
  has n, :aliases
  
  def self.db_matches_for(trigrams)
    sql = "SELECT count(*) AS count, aliases.id, aliases.text, aliases.thing_id FROM trigrams, aliases WHERE token in ? and trigrams.alias_id = aliases.id group by alias_id, aliases.id, aliases.text, aliases.thing_id order by count desc"
    DataMapper.repository(:default).adapter.select(sql, trigrams.to_a).each do |i|
      thing = Thing.get(i.thing_id)
      yield thing,i.text
    end
  end
  
  def self.score(query_trigrams,match_trigrams)
     in_common = (query_trigrams & match_trigrams).length
     total_trigrams = (query_trigrams | match_trigrams).length
     max_checks = 40 # if 40 trigrams match, that's good enough
     score = [max_checks,in_common].min / [max_checks,total_trigrams].min.to_f
  end
  
  def self.matching(query)
    trigrams = query.to_trigrams
    results = {}
    self.db_matches_for(trigrams) do |thing, matching_text|
      score = self.score(trigrams, matching_text.to_trigrams)
      result = [score,thing.id,thing.type,thing.canonical_text]
      
      if results[thing.id] && score > results[thing.id][0]
        results[thing.id] = result 
      else
        results[thing.id] = result if score > 0.5
      end      
    end
    results.values.sort_by {|r| r[0]}.reverse
  end
  
  def add_alias(text,trigrams)
    aka = self.aliases.create(:text => text)
    trigrams.each do |tr|
      aka.trigrams.create(:token=>tr)
    end
  end
  
end

class Alias
  include DataMapper::Resource  
  property :id,          Serial
  property :text,        String, :unique_index => true, :length=> 1..1024

  has n, :trigrams  
  belongs_to :thing
  
end

class Trigram
  include DataMapper::Resource
  property :id,   Serial
  property :token, String, :length => 1..3, :index => true
  belongs_to :alias
end

DataMapper.auto_upgrade!

def clear_database
  DataMapper.repository(:default).adapter.execute("DELETE FROM things")
  DataMapper.repository(:default).adapter.execute("DELETE FROM aliases")
  DataMapper.repository(:default).adapter.execute("DELETE FROM trigrams")
end
