class OriginalStoryAttribution < StoryAttribution
  def initialize(id, title, language, reading_level, authors, text, url_slug, created_at, organization, copy_right_year, script, copy_right_holder)
    super(id, title, language, reading_level, authors, text, url_slug, created_at, organization, true, copy_right_year, script, copy_right_holder)
  end
end
