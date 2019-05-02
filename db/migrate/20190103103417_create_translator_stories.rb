class CreateTranslatorStories < ActiveRecord::Migration
  def change
    create_table :translator_stories do |t|
      t.date :start_date
      t.integer :story_id
      t.integer :translator_id
      t.integer :translator_organization_id
      t.integer :translator_story_id
      t.integer :translate_language_id
    end
  end
end
