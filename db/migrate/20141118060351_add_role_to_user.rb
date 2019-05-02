class AddRoleToUser < ActiveRecord::Migration
  def change
    add_column :users, :role, :integer, null: false
  end
end
