class CreateChildIllustrators < ActiveRecord::Migration
  def change
    create_table :child_illustrators do |t|
      t.string :name
      t.integer :age
      t.integer :illustration_id

      t.timestamps
    end
  end
end
