namespace :stories do
  desc "Create story card for existing stories"
  task create_story_card: :environment do
    FrontCoverPage.includes(:story).where(:"stories.story_card_id" => nil, :"stories.derivation_type" => nil).where.not(:illustration_crop_id => nil).each do |page|
      page.story.create_story_card_with_crop_images()
    end
  end

end
