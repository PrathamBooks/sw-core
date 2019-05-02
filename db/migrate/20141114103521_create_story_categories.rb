class CreateStoryCategories < ActiveRecord::Migration
  def change
    create_table :story_categories do |t|
      t.string :name, null: false, limit: 32

      t.timestamps
    end
    add_index :story_categories, :name
  end
end
