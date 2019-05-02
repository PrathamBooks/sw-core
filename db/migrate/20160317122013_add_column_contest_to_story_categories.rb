class AddColumnContestToStoryCategories < ActiveRecord::Migration
  def change
    add_column :story_categories, :contest_id, :integer
  end
end
