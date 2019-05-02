class AddOrganizationIdToAlbums < ActiveRecord::Migration
  def change
    add_column :albums, :organization_id, :integer
  end
end
