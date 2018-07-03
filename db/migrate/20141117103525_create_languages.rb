class CreateLanguages < ActiveRecord::Migration
  def change
    create_table :languages do |t|
      t.string :name, null: false, limit: 32
      t.boolean :is_right_to_left, default: false
      t.boolean :can_transliterate, default: false

      t.timestamps
    end
    add_index :languages, :name
  end
end
