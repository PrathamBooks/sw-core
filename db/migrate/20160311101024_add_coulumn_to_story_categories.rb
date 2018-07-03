class AddCoulumnToStoryCategories < ActiveRecord::Migration
  def change
    add_column :story_categories, :private, :boolean, :default => false
  end
end
