class AddCommentsToReviewerComments < ActiveRecord::Migration
  def change
  	add_column :reviewer_comments, :comments, :text
  end
end
