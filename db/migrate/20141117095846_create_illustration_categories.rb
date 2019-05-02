class CreateIllustrationCategories < ActiveRecord::Migration
  def change
    create_table :illustration_categories do |t|
      t.string :name, null: false, limit: 32

      t.timestamps
    end
    add_index :illustration_categories, :name
  end
end
