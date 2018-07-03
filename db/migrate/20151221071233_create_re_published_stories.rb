class CreateRePublishedStories < ActiveRecord::Migration
  def change
    create_table :re_published_stories do |t|
    	t.integer :story_id
    	t.integer :previous_status
    	t.datetime :published_at
    	t.integer :user_id

      t.timestamps
    end
  end
end
