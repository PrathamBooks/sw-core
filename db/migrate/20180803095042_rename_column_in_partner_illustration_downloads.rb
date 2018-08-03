class RenameColumnInPartnerIllustrationDownloads < ActiveRecord::Migration
  def change
    remove_column :partner_illustration_downloads, :partner_id
    add_reference :partner_illustration_downloads, :organization
  end
end
