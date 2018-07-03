class AddWebsiteToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :website, :string
  end
end
