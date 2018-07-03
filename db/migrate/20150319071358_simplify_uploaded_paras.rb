class SimplifyUploadedParas < ActiveRecord::Migration
  def change
    Story.where('publisher_id is not null').each do |story|
      story.pages.each do |page|
        page.content = StoryUpload::Ebook.simplify_paras(page).to_s
        page.save!
      end
    end
  end
end
