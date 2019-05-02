class AddStoryCardIdToStories < ActiveRecord::Migration
  def change
    add_column :stories, :story_card_id, :integer
  end
end
