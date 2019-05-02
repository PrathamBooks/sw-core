class ChangeColumnBackgroundColorOfTextbox < ActiveRecord::Migration
  def change
    remove_column :textboxes, :background_color
    add_column :textboxes, :background_color, :integer, :default => 100
  end
end
