class CreateWinners < ActiveRecord::Migration
  def change
    create_table :winners do |t|
    	t.integer :story_id
    	t.integer :contest_id
    	t.string :story_type

      t.timestamps
    end
  end
end
