require 'sinatra'
require 'rake'
require 'rack-session-mongo'
require 'mongo_mapper'
use Rack::Session::Mongo

configure do
  MongoMapper.setup({'production' => {'uri' => ENV['MONGODB_URI']}}, 'production')
end

get "/" do
  session[:data] ||= 1
  session[:data] += 1
  "session[:data] =  #{session[:data]} <br> <a href='/'>Reload</a><br> "
end

class Article
  include MongoMapper::Document

  key :title,        String
  key :content,      String
  key :published_at, Time
  timestamps!
end
