class AddSlugToStoryCategories < ActiveRecord::Migration
  def change
    add_column :story_categories, :card_link, :text    
  end
end
