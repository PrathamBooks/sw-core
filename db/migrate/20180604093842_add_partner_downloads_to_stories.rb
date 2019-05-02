class AddPartnerDownloadsToStories < ActiveRecord::Migration
  def change
    add_column :stories, :partner_downloads, :json    
  end
end
