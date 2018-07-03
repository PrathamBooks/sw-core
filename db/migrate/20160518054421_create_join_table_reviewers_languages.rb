class CreateJoinTableReviewersLanguages < ActiveRecord::Migration
  def change
  	create_join_table :users, :languages, table_name: :reviewers_languages do |t|
      t.index [:user_id, :language_id], name: 'reviewers_languages_index'
    end
  end
end
