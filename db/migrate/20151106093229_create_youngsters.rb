class CreateYoungsters < ActiveRecord::Migration
  def change
    create_table :youngsters do |t|
      t.string :name
      t.integer :age
      t.integer :story_id

      t.timestamps
    end
  end
end
