class AddDescriptionToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :description, :string
  end
end
