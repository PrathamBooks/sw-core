class RenameColumnLocationToCountry < ActiveRecord::Migration
  def change
  	rename_column :institutional_users, :location, :country
  end
end