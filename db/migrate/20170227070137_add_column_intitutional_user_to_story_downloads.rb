class AddColumnIntitutionalUserToStoryDownloads < ActiveRecord::Migration
  def change
  	add_column :story_downloads, :institutional_user, :boolean, :default => false
  end
end
