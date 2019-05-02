class IllustrationStyleTranslations < ActiveRecord::Migration
  def self.up
    IllustrationStyle.create_translation_table!({
      :name => :string,
      :translated_name => :string
    },{
      :migrate_data => true
    })
  end

  def self.down
    IllustrationStyle.drop_translation_table! :migrate_data => true
  end
end
