class AddColumnHighResolutionDownloadsToStory < ActiveRecord::Migration
  def change
    add_column :stories, :high_resolution_downloads, :integer, :default => 0
    add_column :stories, :epub_downloads, :integer, :default => 0
  end
end
