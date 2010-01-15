xml.instruct!
xml.urlset :xmlns => "http://www.sitemaps.org/schemas/sitemap/0.9" do
  @pages.each do |p|
    xml.url do
      xml.loc("#{base_url}#{p[:permalink]}")
      xml.lastmod(p[:xml_date])
    end
  end
end