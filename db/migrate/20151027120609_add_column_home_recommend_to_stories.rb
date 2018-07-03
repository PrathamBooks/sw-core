class AddColumnHomeRecommendToStories < ActiveRecord::Migration
  def change
    add_column :stories, :home_recommended, :boolean, default: false
  end
end
