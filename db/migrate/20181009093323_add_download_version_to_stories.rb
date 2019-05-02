class AddDownloadVersionToStories < ActiveRecord::Migration
  def up
    add_column :stories, :download_version, :integer
  end
  def down
    remove_column :stories, :download_version
  end
end
