class CreateTokens < ActiveRecord::Migration
  def change
    create_table :tokens do |t|
      t.string :access_token, null: false
      t.integer :story_count, default: 0
      t.integer :illustration_count, default: 0
      t.integer :organization_id, null: false
      t.datetime :expires_at
      t.timestamps
    end
  end
end
