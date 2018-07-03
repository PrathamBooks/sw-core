class AddColumnDownloadsToStory < ActiveRecord::Migration
  def change
    add_column :stories, :downloads, :integer, :default => 0
  end
end
