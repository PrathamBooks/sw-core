class CreateUserPopups < ActiveRecord::Migration
  def change
    create_table :user_popups do |t|
      t.string :name
      t.integer :user_id
      t.timestamps
    end
  end
end
