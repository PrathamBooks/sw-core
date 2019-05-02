class CreateListViews < ActiveRecord::Migration
  def change
    create_table :list_views do |t|
      t.integer :user_id
      t.integer :list_id

      t.timestamps
    end
  end
end
