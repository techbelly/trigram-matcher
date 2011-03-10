require 'rubygems'
require 'json'
require 'string-ext'
require 'db'


def make_trigrams
  DataMapper.repository(:default).adapter.execute("DELETE FROM things")
  DataMapper.repository(:default).adapter.execute("DELETE FROM aliases")
  DataMapper.repository(:default).adapter.execute("DELETE FROM trigrams")
  things = JSON.load(open("things.json"))
  things.each do |t|
    type = t['type']
    ignore = t['ignore']
    matches = t['matches']    
    t['matches'].each do |m|
      pk, texts = m[0],m[1]
      db_thing = Thing.create(:type=> type, :canonical_text => texts[0], :pk => pk)
      texts.each do |te|
        te_stripped = te.remove_all(ignore)
        
        my_alias = db_thing.aliases.create(:text => te)
        trigrams = te_stripped.to_trigrams
        trigrams.each do |tr|
          my_alias.trigrams.create(:token=>tr)
        end
  
        if te_stripped != te
          second_alias = db_thing.aliases.create(:text => te_stripped)
          trigrams.each do |tr|
            second_alias.trigrams.create(:token=>tr)
          end
        end
        
      end
    end
  end
end




