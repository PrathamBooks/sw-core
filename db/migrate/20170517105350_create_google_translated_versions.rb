class CreateGoogleTranslatedVersions < ActiveRecord::Migration
  def change
    create_table :google_translated_versions do |t|
      t.integer :page_id
      t.text :google_translated_content
      t.timestamps
    end
  end
end
