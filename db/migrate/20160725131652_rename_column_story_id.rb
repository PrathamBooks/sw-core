class RenameColumnStoryId < ActiveRecord::Migration
  def change
  	rename_column :reviewer_comments, :reviewer_id, :user_id
  end
end
