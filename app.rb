#
# => Fedora: Blogging in style with Sinatra
# => Copyright 2010 Nicholas Young (nicholas at nicholaswyoung.com)
# => (See the included license document or http://www.opensource.org/licenses/mit-license.php for details.)
#
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
require 'rubygems'
require 'sinatra'
require 'builder'
require 'erb'
require 'configuration'
require 'models'

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
  
  def seo_keywords
    "<meta name=\"keywords\" content\"#{Fedora::Configuration.get('seo_keywords')}\">"
  end
  
  def seo_description
    "<meta name=\"description\" content\"#{Fedora::Configuration.get('seo_description')}\">"
  end
  
end

get '/atom.xml' do
  @pages = Fedora::Page.all
  @layout_title = Fedora::Configuration.get('root_title')
  content_type 'application/xml'
  builder :atom
end

get '/sitemap.xml' do
  @pages = Fedora::Page.all
  builder :sitemap
end

get '/archives/:year*' do
  @pages = Fedora::Page.by_year(params[:year])
  @layout_title = Fedora::Configuration.title("Archives for #{params[:year]}")
  erb :archive
end

get '/archives/:year/:month*' do
  @pages = Fedora::Page.by_month(params[:year], params[:month])
  @layout_title = Fedora::Configuration.title("Archives for #{params[:month]}-#{params[:year]}")
  erb :archive
end

get '/' do
  @layout_title = Fedora::Configuration.get('root_title')
  @pages = Fedora::Page.all
  erb :index
end

get '*' do
  @page = Fedora::Page.load(params[:splat].first.to_s)
  @layout_title = Fedora::Configuration.title(@page[:title])
  erb @page[:layout].to_sym
end