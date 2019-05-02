class AddOrganizationUserToIllustrationDownloads < ActiveRecord::Migration
  def change
  	add_column :illustration_downloads, :organization_user, :boolean, :default => false
  end
end
