class CreatePageTemplates < ActiveRecord::Migration
  def change
    create_table :page_templates do |t|
      t.string :name
      t.string :orientation
      t.string :image_position
      t.string :content_position
      t.float :image_dimension
      t.float :content_dimension

      t.timestamps
    end
  end
end
