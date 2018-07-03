class AddColumnsToInstitutionalUser < ActiveRecord::Migration
  def change
  	add_column :institutional_users, :number_of_classrooms, :integer
  	add_column :institutional_users,  :children_impacted, :integer
  	add_column :institutional_users, :organization_name, :string
  end
end
