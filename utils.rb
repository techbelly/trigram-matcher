require 'rubygems'
require 'json'
require 'string-ext'
require 'db'

def make_trigrams
  clear_database
  collections = JSON.load(open("things.json"))
  collections.each do |type|
    type, ignore, matches = type['type'], type['ignore'], type['matches']    
    matches.each do |m|
      pk, texts = *m
      db_thing = Thing.create(:type=> type, :canonical_text => texts.first, :pk => pk)
      texts.each do |text|
        text_stripped = text.remove_all(ignore)
        trigrams = text_stripped.to_trigrams
        
        db_thing.add_alias(text,trigrams)
        if text_stripped != text
          db_thing.add_alias(text_stripped,trigrams)
        end
      end
    end
  end
end




