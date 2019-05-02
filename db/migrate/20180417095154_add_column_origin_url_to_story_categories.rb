class AddColumnOriginUrlToStoryCategories < ActiveRecord::Migration
  def change
    add_column :story_categories, :origin_url, :string
  end
end
