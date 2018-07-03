class AddSiteRolesToUser < ActiveRecord::Migration
  def change
  	add_column :users, :site_roles, :string
  end
end
