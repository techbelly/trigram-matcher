require 'rubygems'
require 'string-ext'
require 'db'
require 'utils'

make_trigrams

def query(s)
  things = Thing.matching(s)
  puts "-----"
  puts s
  puts things.inspect
end

query("Chris Huhne")
query("Secretary of State for the Home Office")
query("Eric Pickles MP")
query("Children and family")
query("Iain Duncan Smith")
query("Universities Minister")