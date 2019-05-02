class AddColumnUploadingToStories < ActiveRecord::Migration
  def change
  	add_column :stories, :uploading, :boolean, :default => false
  end
end
