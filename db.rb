require 'data_mapper'
require 'string-ext'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

class Thing
  include DataMapper::Resource  
  property :id,                    Serial
  property :canonical_text,        String, :length=> 1..1024
  property :type,                  String
  property :pk,                    Integer
  has n, :aliases
  
  def self.matching(query)
    trigrams = query.to_trigrams
    sql = "SELECT count(*) AS count, aliases.* FROM trigrams, aliases WHERE token in ? and trigrams.alias_id = aliases.id group by alias_id order by count desc"
    results = {}
    DataMapper.repository(:default).adapter.select(sql, trigrams).each do |i|
      t = Thing.get(i.thing_id)
      test_trigrams = i.text.to_trigrams
      in_common = (Set.new(trigrams) & Set.new(test_trigrams)).length
      total_trigrams = (Set.new(trigrams) | Set.new(test_trigrams)).length
      max_checks = 40
      score = [max_checks,in_common].min / [max_checks,total_trigrams].min.to_f
      
      r = [score,t.pk,t.type,t.canonical_text]
      if results[i.thing_id] && score > results[i.thing_id][0]
        results[i.thing_id] = r 
      else
        results[i.thing_id] = r if score > 0.5
      end      
    end
    results.values.sort_by {|r| r[0]}.reverse
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