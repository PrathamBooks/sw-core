class CreatePulledDowns < ActiveRecord::Migration
  def change
    create_table :pulled_downs do |t|
      t.string  :pulled_down_type
      t.integer :pulled_down_id
      t.string  :reason

      t.timestamps
    end
  end
end
