class AddColumnTourStatusToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :tour_status, :boolean, :default => false
  end
end
