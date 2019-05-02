class IllustrationCategoryTranslations < ActiveRecord::Migration
  def self.up
    IllustrationCategory.create_translation_table!({
      :name => :string,
      :translated_name => :string
    },{
      :migrate_data => true
    })
  end

  def self.down
    IllustrationCategory.drop_translation_table! :migrate_data => true
  end
end
