class CreateStoryDownloads < ActiveRecord::Migration
  def change
    create_table :story_downloads do |t|
      t.integer :user_id, null: false
      t.integer :story_id, null: false
      t.string  :download_type
      t.string  :ip_address

      t.timestamps
    end
  end
end
