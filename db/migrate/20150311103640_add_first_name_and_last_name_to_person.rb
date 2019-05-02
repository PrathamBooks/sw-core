class AddFirstNameAndLastNameToPerson < ActiveRecord::Migration
  def change
    add_column :people, :first_name, :string
    add_column :people, :last_name, :string
    remove_column :people, :name , :string
  end
end
