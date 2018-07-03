class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.integer :page_template_id
      t.integer :illustration_id
      t.integer :story_id
      t.text :content
      t.float :crop_height
      t.float :crop_width
      t.integer :position

      t.timestamps
    end
  end
end
