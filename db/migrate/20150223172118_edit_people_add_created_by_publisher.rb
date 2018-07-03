class EditPeopleAddCreatedByPublisher < ActiveRecord::Migration
  def change
    add_column :people, :created_by_publisher_id, :integer
    add_index :people, [:created_by_publisher_id]
  end
end
