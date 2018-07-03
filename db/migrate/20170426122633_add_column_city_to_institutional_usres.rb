class AddColumnCityToInstitutionalUsres < ActiveRecord::Migration
  def change
  	add_column :institutional_users, :city, :string
  end
end
