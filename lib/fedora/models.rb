require 'time'
require 'rubygems'
require 'RedCloth'
require 'configuration'

module Fedora
  class Page
    
    attr_reader :file
    attr_accessor :metadata
    
    @metadata = {}
    
    class << self
      
      def create(title, date, author, layout, type)
        # Create a entry here.
      end
      
      def friendly_date(date)
        date = DateTime.parse(date)
        date.strftime("%d %B %Y")
      end

      def date_to_xml(date)
        Time.parse(date).xmlschema
      end

      def parse(string)
        RedCloth.new(string).to_html
      end

      def load(path)
        @path = File.join(Fedora::Configuration.get('content_path'), "#{path}.textile")
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
            :summary => @metadata['summary'] || strip_html(@html)[0..Fedora::Configuration.get('summary_length').to_i]
          }
          return @content
        else
          return "File #{@path} does not exist. Please try again."
        end
      end

      def all
        @files = Array.new
        @i = 0
        file_pattern = File.join(Fedora::Configuration.get('content_path'), "**", "*.textile")
        Dir.glob(file_pattern).each_with_index do |path, i|
          @file = self.load(path.gsub('content', '').gsub('.textile', ''))
          if @file[:type] == 'post'
            @files << self.load(path.gsub('content', '').gsub('.textile', ''))
          end
        end
        sorted = @files.sort_by { |k| k[:sort_date] }
        return sorted.reverse[0..Fedora::Configuration.get('front_page_posts').to_i]
      end
      
      def by_year(year)
        @files = Array.new
        @i = 0
        file_pattern = File.join( Fedora::Configuration.get('content_path'),
                                  Fedora::Configuration.get('posts_path'), year, "**", "*.textile")
        Dir.glob(file_pattern).each_with_index do |path, i|
          @file = self.load(path.gsub('content', '').gsub('.textile', ''))
          if @file[:type] == 'post'
            @files << self.load(path.gsub('content', '').gsub('.textile', ''))
          end
        end
        sorted = @files.sort_by { |k| k[:sort_date] }
        return sorted.reverse
      end
      
      def by_month(year, month)
        @files = Array.new
        @i = 0
        file_pattern = File.join( Fedora::Configuration.get('content_path'), 
                                  Fedora::Configuration.get('posts_path'), year, month, "*.textile")
        Dir.glob(file_pattern).each_with_index do |path, i|
          @file = self.load(path.gsub('content', '').gsub('.textile', ''))
          if @file[:type] == 'post'
            @files << self.load(path.gsub('content', '').gsub('.textile', ''))
          end
        end
        sorted = @files.sort_by { |k| k[:sort_date] }
        return sorted.reverse
      end

      def paragraph_is_metadata(text)
        text.split("\n").first =~ /^[\w ]+:/
      end
      
      def strip_html(html)
        html.gsub(/<\/?[^>]*>/, "")
      end
    end
  end
end