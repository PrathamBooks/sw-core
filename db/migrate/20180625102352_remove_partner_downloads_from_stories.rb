class RemovePartnerDownloadsFromStories < ActiveRecord::Migration
  def change
    remove_column :stories, :partner_downloads, :json    
  end
end
