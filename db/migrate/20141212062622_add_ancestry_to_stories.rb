class AddAncestryToStories < ActiveRecord::Migration
  def up
    add_column :stories, :ancestry, :string
    add_index :stories, :ancestry
  end
  def down
    remove_index :stories, :ancestry
    remove_column :stories, :ancestry, :string
  end
end
