class CreatePartnerStoryDownloads < ActiveRecord::Migration
  def change
    create_table :partner_story_downloads do |t|
      t.string :partner_id, :null => false
      t.string :story_uuid, :null => false
      t.integer :total_downloads, :default => 0
      t.integer :epub_downloads, :default => 0
      t.integer :low_res_pdf_downloads, :default => 0
      t.integer :high_res_pdf_downloads, :default => 0
      t.timestamps
    end
  end
end
