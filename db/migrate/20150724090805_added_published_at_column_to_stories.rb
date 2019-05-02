class AddedPublishedAtColumnToStories < ActiveRecord::Migration
  def change
  	add_column :stories, :published_at, :datetime
  	stories = Story.where(["status = ? and published_at IS NULL", 1])
	stories.each do |story|
		story.update_attribute(:published_at, story.created_at)
	end
  end
end
