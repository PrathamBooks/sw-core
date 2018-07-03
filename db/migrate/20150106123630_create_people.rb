class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :name
      t.belongs_to :user
      t.timestamps
    end
  end
end
