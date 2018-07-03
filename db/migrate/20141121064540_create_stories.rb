class CreateStories < ActiveRecord::Migration
  def change
    create_table :stories do |t|
      t.string :title, null: false, limit: 255
      t.string :english_title, limit: 255
      t.integer :language_id, null: false
      t.integer :reading_level, null: false
      t.integer :status, null: false, default: 0
      t.string :synopsis, null: true, limit: 255 
      t.integer :publisher_id, null: true 
      t.timestamps
    end
  end
end
