class AddRecommendationsToStories < ActiveRecord::Migration
  def change
    add_column :stories, :recommendations, :string
  end
end
