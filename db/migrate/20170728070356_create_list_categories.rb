class CreateListCategories < ActiveRecord::Migration
  def change
    create_table :list_categories do |t|
      t.string :name, null: false, limit: 32
      t.timestamps
    end
    add_index :list_categories, :name
  end
end
