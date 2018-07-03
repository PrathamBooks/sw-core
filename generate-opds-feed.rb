def sanitize(val)
  val.sub("&", "&amp;")
end

def host_url
  ENV['rootUrl'] ? ENV['rootUrl'] : "http://localhost:3000"
end

File.open("public/assets/media/catalog.atom", 'w') do |f|
  f.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
  f.write("<feed xmlns=\"http://www.w3.org/2005/Atom\" xmlns:dcterms=\"http://purl.org/dc/terms/\" 
    xmlns:dc=\"http://purl.org/dc/terms/\" xmlns:opds=\"http://opds-spec.org/2010/catalog\">\n\n")
  f.write("<id>#{host_url}</id>\n")
  f.write("<title>Storyweaver Feed</title>\n")
  f.write("<updated>#{Time.now.strftime("%Y-%m-%d") + "T" + Time.now.strftime("%H:%M:%S") + "Z"}</updated>\n")
  f.write("<link rel=\"self\" href=\"https://storyweaver.org.in\" type=\"application/atom+xml;profile=opds-catalog;kind=acquisition\"/>\n")
  f.write("<link rel=\"start\" href=\"https://storyweaver.org.in\" type=\"application/atom+xml;profile=opds-catalog;kind=acquisition\"/>\n")
  f.write("\n")
  stories = Story.published
  stories.each do |s|
    f.write("<entry>\n")
    f.write("<title>#{sanitize(s.title)}</title>\n")
    f.write("<id>#{s.uuid}</id>\n")
    f.write("<summary>#{s.reading_level}</summary>\n")
    if s.language != nil
      f.write("<dcterms:language>#{sanitize(s.language.name)}</dcterms:language>\n")
    else
      f.write("<dcterms:language></dcterms:language>\n")
    end      
    if s.organization != nil
      f.write("<dcterms:publisher>#{sanitize(s.organization.organization_name)}</dcterms:publisher>\n")
    else
      f.write("<dcterms:publisher></dcterms:publisher>\n")
    end      
    f.write("<updated>#{s.updated_at.strftime("%Y-%m-%d") + "T" + s.updated_at.strftime("%H:%M:%S") + "Z"}</updated>\n")
    f.write("<link rel=\"http://opds-spec.org/acquisition\" href=\"#{host_url}/api/v0/story/pdf/#{s.uuid}\" type=\"application/pdf+zip\"/>\n")
    f.write("<link rel=\"http://opds-spec.org/acquisition\" href=\"#{host_url}/api/v0/story/epub/#{s.uuid}\" type=\"application/epub+zip\"/>\n")
    f.write("</entry>\n")
  end  
  f.write("</feed>")
end
