include ApplicationHelper

def host_url
  ENV['rootUrl'] ? ENV['rootUrl'] : "http://localhost:3000"
end

# TODO: fix duplication of uuids issue, story uuid should be set correctly after story record is created
Story.update_all(["uuid = CONCAT(?, id)", "#{Settings.org_info.prefix}-"])

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
  stories = Story.where.not(organization_id: nil).where(status: Story.statuses[:published])
  stories.each do |s|
    puts "### creating entry for story with ID : #{s.id}"
    f.write("<entry>\n")
    f.write("<title>#{escape_characters_for_xml(s.title)}</title>\n")
    f.write("<id>#{s.uuid}</id>\n")
    f.write("<summary>#{escape_characters_for_xml(s.synopsis)}</summary>\n")
    s.authors.each do |author|
      f.write("<author><name>#{escape_characters_for_xml(author.name)}</name></author>\n")
    end
    # TODO: using contributor element for illustrator, change if closer element found
    s.illustrators.each do |illustrator|
      f.write("<contributor><name>#{escape_characters_for_xml(illustrator.name)}</name></contributor>\n")
    end
    if s.language != nil
      f.write("<dcterms:language>#{escape_characters_for_xml(s.language.name)}</dcterms:language>\n")
    else
      f.write("<dcterms:language></dcterms:language>\n")
    end
    # TODO: using category element for reading level, change if closer element found
    f.write("<category term=\"#{s.reading_level}\" label=\"Level #{s.reading_level} Stories\"/>\n")
    if !s.story_card.nil?
      f.write("<link type=\"image/jpeg\" href=\"#{s.story_card.illustration_crop.image(:size7)}\" rel=\"http://opds-spec.org/image\"/>\n")
      f.write("<link type=\"image/jpeg\" href=\"#{s.story_card.illustration_crop.image(:page_portrait)}\" rel=\"http://opds-spec.org/image/thumbnail\"/>\n")
    end
    if s.organization != nil
      f.write("<dcterms:publisher>#{escape_characters_for_xml(s.organization.organization_name)}</dcterms:publisher>\n")
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