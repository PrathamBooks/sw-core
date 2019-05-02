class CreateRecommendations < ActiveRecord::Migration
  def change
    create_table :recommendations do |t|
      t.integer :recommendable_id
      t.string  :recommendable_type

      t.timestamps
    end
  end
end
