class CreateDonars < ActiveRecord::Migration
  def change
    create_table :donars do |t|
      t.string :name
      t.string :credit_line

      t.timestamps
    end
  end
end
