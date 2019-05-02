class CreateTextboxes < ActiveRecord::Migration
  def change
    create_table :textboxes do |t|
      t.text :content
      t.string :background_color, default: "#ffffff"
      t.decimal :textbox_position_left, precision: 5, scale: 2
      t.decimal :textbox_position_top, precision: 5, scale: 2
      t.decimal :textbox_width, precision: 5, scale: 2
      t.decimal :textbox_height, precision: 5, scale: 2
      t.references :page, polymorphic: true, index: true

      t.timestamps
    end
  end
end
