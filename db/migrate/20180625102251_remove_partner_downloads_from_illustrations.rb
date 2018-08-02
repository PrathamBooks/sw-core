class RemovePartnerDownloadsFromIllustrations < ActiveRecord::Migration
  def change
    remove_column :illustrations, :partner_downloads
  end
end
