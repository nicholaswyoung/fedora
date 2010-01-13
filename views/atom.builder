xml.instruct!
xml.feed :xmlns => "http://www.w3.org/2005/Atom" do
  xml.title @layout_title, :type => "text"
  xml.generator "Fedora", :uri => "http://nicholaswyoung.com/software/fedora"
  xml.link :href => "#{base_url}/feed", :rel => "self"
  xml.link :href => base_url, :rel => "alternate"
  @pages.each do |page|
    xml.entry do
      xml.title page[:title]
      xml.link :href => "#{base_url}#{page[:permalink]}",
               :type => "text/html",
               :rel => "alternate"
      xml.content page[:body], :type => "html"
      xml.published page[:xml_date]
    end
  end
end