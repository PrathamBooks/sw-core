class CreatePiwikEvents < ActiveRecord::Migration
  def change
    create_table :piwik_events do |t|
      t.string :category, null: false
      t.string :action, null: false
      t.string :name, null: true
      t.integer :value, null: true
      t.timestamps
    end
  end
end
