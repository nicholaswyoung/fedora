require 'yaml'
require 'rubygems'
require 'sinatra'

module Fedora
  class Configuration
    @config_file = nil
    
    class << self
      def get(key)
        configuration[key]
      end
      
      def title(entry_title)
        @title = configuration["title_format"].gsub('%site_name%', configuration["site_name"])
        @title = @title.gsub('%entry_title%', entry_title) unless entry_title.nil?
      end
      
      private
        def environment
          Sinatra::Application.environment.to_s
        end

        def configuration
          file = File.join(File.dirname(__FILE__), "../config/config.yml")
          @config_file ||= YAML::load(IO.read(file))
        end
    end
  end
end