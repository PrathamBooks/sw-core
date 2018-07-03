class AddColumnTimestampsToReviewersLanguages < ActiveRecord::Migration
  def change
  	 add_column :reviewers_languages, :created_at, :datetime
  	 add_column :reviewers_languages, :updated_at, :datetime
  end
end
