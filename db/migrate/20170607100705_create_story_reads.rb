class CreateStoryReads < ActiveRecord::Migration
  def change
    create_table :story_reads do |t|
    	t.integer :story_id
    	t.integer :user_id
    	t.boolean :is_completed, default: false
    	t.datetime :finished_at

      t.timestamps
    end
  end
end
