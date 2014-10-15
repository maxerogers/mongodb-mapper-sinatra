require 'rubygems'
require 'bundler'
Bundler.require(:default)

use Rack::Session::Mongo

class Shorten
  include MongoMapper::Document

  key :url,        String
  key :shorten_id, String
  key :created_at, Time
  key :count,      Integer

end

configure do
  MongoMapper.database = 'urls'
end



get "/" do
  session[:data] ||= 1
  session[:data] += 1
  @shortens = Shorten.sort(:created_at.desc).limit(10)
  haml :index
end

post "/create" do
  @shorten = Shorten.where(:url=>params[:shorten][:url]).first
  if @shorten.nil?
    shorten_id = Shorten.all.count.to_s(16)
    @shorten = Shorten.new(:url=>params[:shorten][:url], :shorten_id=>shorten_id, :created_at=>Time.new, :count=>0)
    @shorten.save
  end
  redirect "/#{@shorten.shorten_id}/info"
end

get "/:id" do |id|
  @shorten = Shorten.where(:shorten_id=>id).first
  unless @shorten.nil?
    @shorten.count += 1
    @shorten.save
    redirect @shorten.url
  end
  redirect "/"
end

get "/:id/info" do |id|
  @shorten = Shorten.where(:shorten_id=>id).first
  if @shorten.nil?
    redirect "/"
  end
  haml :info
end

__END__
@@layout
!!! 5
%html
  %head
    %title Sinatra and MongoMapper Url Shortener
  %body
  =yield
  %strong= session[:data]
@@index
%form{:action=>"/create", :method=>"post"}
  %div
    %label{:for=>"url"} URL:
    %input#url{:type=>"url", :placeholder=>"http://", :name=>"shorten[url]"}
  %div
    %input{:type=>"submit", :value=>"Submit"}
    %input{:type=>"reset", :value=>"Clear"}
#list{:style=>"margin-top: 20px;"}
  - @shortens.each do |shorten|
    %div
      %span.url{:style=>"margin-right: 50px;"}
        %a{:href=>"/#{shorten.shorten_id}"}= "#{shorten.url}"
      %span.count{:style=>"margin-right: 50px;"}= "#{shorten.count}"
      %span.info{:style=>"margin-right: 50px;"}
        %a{:href=>"/#{shorten.shorten_id}/info"} Info Page
@@info
%div
  %p= "URL: #{@shorten.url}"
  %p= "Shorten URL: http://#{request.host}/#{@shorten.shorten_id}"
  %p= "Created at: #{@shorten.created_at}"
  %p= "Count: #{@shorten.count}"
