class CreateJoinTableStoryCategoriesStories < ActiveRecord::Migration
  def change
    create_join_table :story_categories, :stories do |t|
      t.index [:story_category_id, :story_id], name: 'category_story_index'
    end
  end
end
