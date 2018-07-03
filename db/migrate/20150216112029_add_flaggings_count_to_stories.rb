class AddFlaggingsCountToStories < ActiveRecord::Migration
  def change
    add_column :stories, :flaggings_count, :integer
  end
end
