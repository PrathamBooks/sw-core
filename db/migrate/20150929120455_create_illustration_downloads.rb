class CreateIllustrationDownloads < ActiveRecord::Migration
  def change
    create_table :illustration_downloads do |t|
      t.integer :user_id, null: false
      t.integer :illustration_id, null: false
      t.string  :download_type
      t.string  :ip_address

      t.timestamps
    end
  end
end
