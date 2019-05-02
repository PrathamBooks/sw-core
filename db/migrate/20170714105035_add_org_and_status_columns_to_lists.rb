class AddOrgAndStatusColumnsToLists < ActiveRecord::Migration
  def change
    add_column :lists, :organization_id, :integer
    add_column :lists, :status, :integer, null: false, default: 0
  end
end
