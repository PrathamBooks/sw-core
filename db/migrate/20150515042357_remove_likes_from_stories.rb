class RemoveLikesFromStories < ActiveRecord::Migration
  def change
    remove_column :stories, :likes
  end
end
