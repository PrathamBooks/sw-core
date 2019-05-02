class StoryCard < Page
  def story
    Story.where(:derivation_type => nil).find_by(:story_card_id => id)
  end
end
