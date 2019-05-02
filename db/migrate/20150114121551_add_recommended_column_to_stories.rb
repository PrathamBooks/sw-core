class AddRecommendedColumnToStories < ActiveRecord::Migration
  def change
    add_column :stories, :recommended, :boolean , default: false
  end
end
