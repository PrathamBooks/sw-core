class CreateBanners < ActiveRecord::Migration
  def change
    create_table :banners do |t|
      t.string :name
      t.boolean :is_active, default: false
      t.string :link_path
      t.integer :position

      t.timestamps
    end
  end
end
