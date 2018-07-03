class AddAndRenameColumnstoStoryDownloads < ActiveRecord::Migration
  def change
  	rename_column :story_downloads, :institutional_user, :organization_user
  	add_column :story_downloads, :org_id, :integer
  end
end