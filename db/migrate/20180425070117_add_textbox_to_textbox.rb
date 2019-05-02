class AddTextboxToTextbox < ActiveRecord::Migration
  def change
    add_reference :textboxes, :root_textbox, index: true
  end
end
