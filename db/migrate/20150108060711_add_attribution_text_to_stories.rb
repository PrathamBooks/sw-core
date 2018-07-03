class AddAttributionTextToStories < ActiveRecord::Migration
  def change
    add_column :stories, :attribution_text, :string, limit: 255
  end
end
