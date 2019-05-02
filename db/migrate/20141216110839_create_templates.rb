class CreateTemplates < ActiveRecord::Migration
  def change
    create_table :templates do |t|
      t.string  :name
      t.string  :orientation
      t.string  :image_position
      t.string  :content_position
      t.integer :image_dimension
      t.integer :content_dimension
      t.string  :type
      t.timestamps
    end
  end
end
