class RemoveColumnOtherComments < ActiveRecord::Migration
  def change
  	remove_column :reviewer_comments, :other_comments
  end
end
