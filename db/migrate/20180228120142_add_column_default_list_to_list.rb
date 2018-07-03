class AddColumnDefaultListToList < ActiveRecord::Migration
  def change
  	add_column :lists, :is_default_list, :boolean, :default => false
  end
end
