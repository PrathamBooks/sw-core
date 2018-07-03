class StoryAttribution < Attribution
  attr_reader :id, :title, :language, :reading_level, :authors, :text, :created_at, :organization, :is_original_story, :copy_right_year, :script, :copy_right_holder

  def initialize(id, title, language, reading_level, authors, text, url_slug, created_at, organization, is_original_story, copy_right_year, script, copy_right_holder)
    @id = id
    @title = title
    @language = language
    @reading_level = reading_level
    @authors = authors
    @text = text
    @url_slug = url_slug
    @created_at = created_at
    @organization = organization
    @is_original_story = is_original_story
    @copy_right_year = copy_right_year
    @script = script
    @copy_right_holder = copy_right_holder
  end

  def copyright_holder
    organization.nil? ?
      authors.collect(&:name).join(', ') :
      (copy_right_holder.nil? ? organization.organization_name : copy_right_holder)
  end

  def ==(other_object)
    if(other_object == nil)
      return false
    elsif (self.class != other_object.class)
      return false
    else
      return @id == other_object.id && 
        @title == other_object.title &&
        @language == other_object.language &&
        @reading_level == other_object.reading_level &&
        @authors == other_object.authors &&
        @text == other_object.text &&
        @url_slug == other_object.url_slug &&
        @copy_right_year == other_object.copy_right_year
    end
  end
end
