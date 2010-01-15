#
# => Fedora: Blogging in style with Sinatra
# => Copyright 2010 Nicholas Young (nicholas at nicholaswyoung.com)
# => (See the included license document or http://www.opensource.org/licenses/mit-license.php for details.)
#

require 'rubygems'
require 'sinatra'
require 'builder'
require 'erb'
require 'lib/configuration'
require 'lib/models'

puts "== Putting on his hat..."

set :cache_enabled, false
set :static, true

helpers do

  def base_url
    url = "http://#{request.host}"
    request.port == 80 ? url : url + ":#{request.port}"
  end
  
  def link_url
    "http://#{Fedora::Configuration.get('host')}"
  end
  
  def disqus_short_name
    Fedora::Configuration.get('disqus_short_name')
  end
  
end

get '/atom.xml' do
  @pages = Fedora::Page.all
  @layout_title = Fedora::Configuration.get('root_title')
  content_type 'application/xml'
  builder :atom
end

get '/sitemap.xml' do
  "Coming soon!"
end

get '/' do
  @layout_title = Fedora::Configuration.get('root_title')
  @pages = Fedora::Page.all
  erb :index
end

get '*' do
  @page = Fedora::Page.load(params[:splat].first.to_s)
  @layout_title = Fedora::Configuration.title(@page[:title])
  erb :page
end