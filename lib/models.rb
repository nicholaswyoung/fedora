require 'time'
require 'rubygems'
require 'RedCloth'
require 'configuration'

module Fedora
  class Page
    
    attr_reader :file
    attr_accessor :metadata
    
    @metadata = {}
    
    def self.friendly_date(date)
      date = DateTime.parse(date)
      date.strftime("%d %B %Y")
    end
    
    def self.date_to_xml(date)
      Time.parse(date).xmlschema
    end
    
    def self.parse(string)
      RedCloth.new(string).to_html
    end
    
    def self.load(path)
      @path = File.join(Fedora::Configuration.content_path, "#{path}.textile")
      if File.exist?(@path)
        first_para, remaining = File.open(@path).read.split(/\r?\n\r?\n/, 2)
        if self.paragraph_is_metadata(first_para)
          @markup = remaining
          for line in first_para.split("\n") do
            key, value = line.split(/\s*:\s*/, 2)
            @metadata[key.downcase] = value.chomp
          end
        else
          @markup = [first_para, remaining].join("\n\n")
        end
        @html = self.parse(@markup.to_s)
        @content = {
          :body => @html,
          :permalink => path,
          :date => self.friendly_date(@metadata['date']),
          :sort_date => @metadata['date'],
          :xml_date => self.date_to_xml(@metadata['date']),
          :title => @metadata['title'],
          :type => @metadata['type'] || 'post',
          :layout => @metadata['layout'] || 'page',
          :author => @metadata['author'],
          :summary => @metadata['summary'] || @html.gsub(/<\/?[^>]*>/, "")[0..Fedora::Configuration.summary_length]
        }
        return @content
      else
        return "File #{@path} does not exist. Please try again."
      end
    end
    
    def self.all
      @files = Array.new
      @i = 0
      file_pattern = File.join(Fedora::Configuration.content_path, "**", "*.textile")
      Dir.glob(file_pattern).each_with_index do |path, i|
        @file = self.load(path.gsub('content', '').gsub('.textile', ''))
        if @file[:type] == 'post'
          @files << self.load(path.gsub('content', '').gsub('.textile', ''))
        end
      end
      sorted = @files.sort_by { |k| k[:sort_date] }
      return sorted.reverse[0..Fedora::Configuration.front_page_posts]
    end
    
    def self.paragraph_is_metadata(text)
      text.split("\n").first =~ /^[\w ]+:/
    end

  end
end