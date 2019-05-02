class AddAttributionTextIllustrator < ActiveRecord::Migration
  def change
    add_column :illustrations, :attribution_text, :string, limit: 255
  end
end
