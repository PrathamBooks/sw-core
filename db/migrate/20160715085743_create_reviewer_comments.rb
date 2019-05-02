class CreateReviewerComments < ActiveRecord::Migration
  def change
    create_table :reviewer_comments do |t|
	  t.integer :story_id
      t.integer :reviewer_id
      t.integer :story_rating
      t.integer :language_rating
      t.integer :content_type
      t.integer :image_quality
      t.boolean :recommend
      t.string :other_comments
      
      t.timestamps
    end
  end
end