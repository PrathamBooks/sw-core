class AddIdToListsStoriesTable < ActiveRecord::Migration
  def change
    add_column :lists_stories, :id, :primary_key
    add_column :lists_stories, :position, :integer
    add_column :lists_stories, :created_at, :datetime
    add_column :lists_stories, :updated_at, :datetime
  end
end
