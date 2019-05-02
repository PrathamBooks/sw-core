class AddColumnsToStory < ActiveRecord::Migration
  def change
    add_column :stories, :started_translation_at, :datetime
    add_column :stories, :is_autoTranslate, :boolean
  end
end
