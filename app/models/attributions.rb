class Attributions < Array
  def add_self(story, is_original_story)
    self << SelfAttribution.new(story.id, story.title, story.language.name, story.reading_level, story.authors, story.attribution_text, story.to_param, story.created_at, story.organization, story.derivation_type, is_original_story, story.copy_right_year, story.language.script, story.copy_right_holder.present? ? story.copy_right_holder.name : nil)
  end

  def add_original_story_attribution(original_story)
    self << OriginalStoryAttribution.new(original_story.id, original_story.title, original_story.language.name, original_story.reading_level, original_story.authors, original_story.attribution_text, original_story.to_param, original_story.created_at, original_story.organization, original_story.copy_right_year, original_story.language.script, original_story.copy_right_holder.present? ? original_story.copy_right_holder.name : nil)
  end

  def add_parent_story_attribution(parent_story)
    self << ParentStoryAttribution.new(parent_story.id, parent_story.title, parent_story.language.name, parent_story.reading_level, parent_story.authors, parent_story.attribution_text, parent_story.to_param, parent_story.created_at, parent_story.organization, parent_story.copy_right_year, parent_story.language.script, parent_story.copy_right_holder.present? ? parent_story.copy_right_holder.name : nil)
  end

  def add_illustration_attribution(page_position, illustration, story)
    self << IllustrationAttribution.new(page_position, illustration.illustrators.map(&:name), illustration.illustrators.map(&:id), illustration.copy_right_year, illustration.name, illustration.license_type, illustration.to_param, story, illustration.uploader, illustration.org_copy_right_holder.present? ? illustration.org_copy_right_holder.organization_name : nil, illustration.photographers.map(&:name), illustration.photographers.map(&:slug))
  end
end
