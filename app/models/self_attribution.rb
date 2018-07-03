class SelfAttribution < StoryAttribution
  attr_reader :derivation_type

  def initialize(id, title, language, reading_level, authors, text, url_slug, created_at, organization, derivation_type, is_original_story, copy_right_year, script, copy_right_holder)
    super(id, title, language, reading_level, authors, text, url_slug, created_at, organization, is_original_story, copy_right_year, script, copy_right_holder)
    @derivation_type = derivation_type
  end

  def story_action_type
    if derivation_type.nil?
      return 'written'
    else derivation_type == 'translated' ? 'translated' : 're-levelled'
    end
  end
end
