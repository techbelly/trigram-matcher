require 'rubygems'
require 'sinatra'
require 'db'
require 'utils'
require 'json'

get '/' do
  """
  <html>
  <body>
  <h1>Search</h1>
  <form action=\"/search\" method=\"GET\">
    <input type=\"text\" name=\"q\">
    <input type=\"submit\" value=\"Search\">
  </form>
  </body>
  </html>
  """
end

get '/search' do
  query = params[:q]
  things = Thing.matching(query)
  content_type :json
  things.to_json
end

get '/__reparse' do
  make_trigrams
  "REPARSED."
end

