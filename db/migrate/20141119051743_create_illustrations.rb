class CreateIllustrations < ActiveRecord::Migration
  def change
    create_table :illustrations do |t|
      t.string :name, null: false, limit: 255
      t.integer :illustrator_id
      t.timestamps
    end
  end
end
