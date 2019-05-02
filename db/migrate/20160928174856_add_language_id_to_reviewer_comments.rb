class AddLanguageIdToReviewerComments < ActiveRecord::Migration
  def change
  	add_column :reviewer_comments, :language_id, :integer
  end
end
