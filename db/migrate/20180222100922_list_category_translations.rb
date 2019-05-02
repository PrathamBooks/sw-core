class ListCategoryTranslations < ActiveRecord::Migration
  def self.up
    ListCategory.create_translation_table!({
      :name => :string,
      :translated_name => :string
    },{
      :migrate_data => true
    })
  end

  def self.down
    ListCategory.drop_translation_table! :migrate_data => true
  end
end
