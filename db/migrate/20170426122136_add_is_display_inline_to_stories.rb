class AddIsDisplayInlineToStories < ActiveRecord::Migration
  def change
    add_column :stories, :is_display_inline, :boolean, :default => true
  end
end
