class OrgTranslations < ActiveRecord::Migration
  def self.up
    Organization.create_translation_table!({
      :organization_name => :string,
      :translated_name => :string
    },{
      :migrate_data => true
    })
  end

  def self.down
    Organization.drop_translation_table! :migrate_data => true
  end
end
