class AddColumnOriginUrlToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :origin_url, :string
  end
end
