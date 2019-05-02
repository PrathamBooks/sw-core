class AddColumnUuidToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :uuid, :string
  end
end
