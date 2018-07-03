class AddColumnHowToUseToListsStories < ActiveRecord::Migration
  def change
    add_column :lists_stories, :how_to_use, :string, limit: 750
  end
end
