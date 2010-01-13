require 'yaml'
require 'rubygems'
require 'sinatra'

module Fedora
  class Configuration
    @config_file = nil
    
    def self.title(entry_title)
      @title = self.configuration["title_format"].gsub('%site_name%', self.configuration["site_name"])
      @title = @title.gsub('%entry_title%', entry_title) unless entry_title.nil?
    end
    
    def self.front_page_posts
      self.configuration["front_page_posts"].to_i - 1
    end
    
    def self.host
      self.configuration["host"]
    end
    
    def self.disqus_short_name
      self.configuration["disqus_short_name"].to_s
    end
    
    def self.summary_length
      self.configuration["summary_length"].to_i
    end
    
    def self.attachment_path
      if self.configuration["attachment_directory"].include?('http')
        return self.configuration["attachment_directory"]
      else
        return "#{self.host}/#{self.configuration["attachment_directory"]}"
      end
    end
    
    def self.index_title
      self.configuration["root_title"]
    end
    
    def self.content_path(basename = nil)
      self.configuration["content_directory"]
    end
    
    private
      def self.environment
        Sinatra::Application.environment.to_s
      end
    
      def self.configuration
        file = File.join(File.dirname(__FILE__), "../config/config.yml")
        @config_file ||= YAML::load(IO.read(file))
      end
  end
end