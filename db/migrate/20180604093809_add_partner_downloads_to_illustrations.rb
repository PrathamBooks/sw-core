class AddPartnerDownloadsToIllustrations < ActiveRecord::Migration
  def change
    add_column :illustrations, :partner_downloads, :json    
  end
end
