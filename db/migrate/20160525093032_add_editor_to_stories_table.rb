class AddEditorToStoriesTable < ActiveRecord::Migration
  def change
  	add_column :stories, :editor_id, :integer
  	add_column :stories, :editor_status, :boolean, :default => false
  end
end
