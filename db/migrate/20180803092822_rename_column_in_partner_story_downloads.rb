class RenameColumnInPartnerStoryDownloads < ActiveRecord::Migration
  def change
    remove_column :partner_story_downloads, :partner_id
    add_reference :partner_story_downloads, :organization
  end
end
