class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
    	t.integer :rateable_id
    	t.string :rateable_type
    	t.integer :user_id
    	t.string :user_comment
    	t.float :user_rating

        t.timestamps
    end
  end
end
