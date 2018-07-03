class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :organization_name
      t.string :organization_type
      t.string :country
      t.string :city
      t.integer :number_of_classrooms
      t.integer :children_impacted
      t.string :status
      t.attachment :logo

      t.timestamps
    end
  end
end
