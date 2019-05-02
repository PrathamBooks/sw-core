class CreateSmileyRatings < ActiveRecord::Migration
  def change
    create_table :smiley_ratings do |t|
    	t.integer :story_id
    	t.integer :user_id
    	t.string :reaction

      t.timestamps
    end
  end
end
