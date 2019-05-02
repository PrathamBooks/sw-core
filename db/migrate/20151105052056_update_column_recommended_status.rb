class UpdateColumnRecommendedStatus < ActiveRecord::Migration
  def change
    remove_column :stories, :recommended_status
    add_column :stories, :recommended_status, :integer
  end
end
