class AddDownloadedCountColumnToUser < ActiveRecord::Migration
  def change
  	add_column :users, :story_download_count, :integer, :default => 0
  	add_column :users, :illustration_download_count, :integer, :default => 0
  end
end
