class ChangeColumnToReviewerComments < ActiveRecord::Migration
  def change
  	remove_column :reviewer_comments, :content_type
  	remove_column :reviewer_comments, :image_quality
  	remove_column :reviewer_comments, :recommend
  	add_column :reviewer_comments, :rating, :integer
  end
end
