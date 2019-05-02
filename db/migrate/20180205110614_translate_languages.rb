class TranslateLanguages < ActiveRecord::Migration
  def self.up
    Language.create_translation_table!({
      :name => :string,
      :translated_name => :string
    },{
      :migrate_data => true
    })
  end

  def self.down
    Language.drop_translation_table! :migrate_data => true
  end

end
