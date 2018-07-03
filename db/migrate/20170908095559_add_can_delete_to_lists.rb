class AddCanDeleteToLists < ActiveRecord::Migration
  def change
    add_column :lists, :can_delete, :boolean, :default => true
  end
end
