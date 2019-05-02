class AddColumnUuidToStoryCategories < ActiveRecord::Migration
  def change
    add_column :story_categories, :uuid, :string
  end
end
