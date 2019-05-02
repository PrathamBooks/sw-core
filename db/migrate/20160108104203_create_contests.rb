class CreateContests < ActiveRecord::Migration
  def change
    create_table :contests do |t|
    	t.string :name
    	t.datetime :start_date
    	t.datetime :end_date
    	t.string :contest_type

      t.timestamps
    end
  end
end
