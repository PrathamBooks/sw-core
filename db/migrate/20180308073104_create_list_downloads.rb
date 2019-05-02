class CreateListDownloads < ActiveRecord::Migration
  def change
    create_table :list_downloads do |t|
      t.integer :user_id, null: false
      t.integer :list_id, null: false
      t.datetime :when
      t.string  :ip_address
    end
    add_index :list_downloads, [:user_id, :list_id]
  end
end
