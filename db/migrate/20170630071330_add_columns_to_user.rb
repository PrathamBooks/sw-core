class AddColumnsToUser < ActiveRecord::Migration
  def change
    add_column :users, :organization_id, :integer
    add_column :users, :organization_roles, :string
  end
end
