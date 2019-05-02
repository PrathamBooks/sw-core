class AddColumnEditorRecommendedToStories < ActiveRecord::Migration
  def change
    add_column :stories, :editor_recommended, :boolean, :default => false
  end
end
