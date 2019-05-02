class AddActiveOnHomeToStoryCategories < ActiveRecord::Migration
  def change
    add_column :story_categories, :active_on_home, :boolean, :default => false
  end
end
