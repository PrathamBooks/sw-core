class AddColumnBoundaryToTextboxes < ActiveRecord::Migration
  def change
    add_column :textboxes, :boundary, :boolean, default: false
  end
end
