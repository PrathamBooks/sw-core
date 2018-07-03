class CategoryTranslations < ActiveRecord::Migration
  def self.up
    StoryCategory.create_translation_table!({
      :name => :string,
      :translated_name => :string
    },{
      :migrate_data => true
    })
  end

  def self.down
    StoryCategory.drop_translation_table! :migrate_data => true
  end
end
