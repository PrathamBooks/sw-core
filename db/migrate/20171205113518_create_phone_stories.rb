class CreatePhoneStories < ActiveRecord::Migration
  def change
    create_table :phone_stories do |t|
      t.integer :story_id
      t.text :text
      t.string :link

      t.timestamps
    end
  end
end
