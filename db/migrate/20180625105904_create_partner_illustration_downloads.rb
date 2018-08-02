class CreatePartnerIllustrationDownloads < ActiveRecord::Migration
  def change
    create_table :partner_illustration_downloads do |t|
      t.string :partner_id, :null => false
      t.string :illustration_uuid, :null => false
      t.integer :downloads, :default => 0
      t.timestamps
    end
  end
end
