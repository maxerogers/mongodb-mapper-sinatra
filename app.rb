require 'sinatra'
require 'rake'
require 'rack-session-mongo'
require 'mongo_mapper'
use Rack::Session::Mongo

get "/" do
  session[:data] ||= 1
  session[:data] += 1
  "session[:data] =  #{session[:data]} <br> <a href='/'>Reload</a><br> "
end
