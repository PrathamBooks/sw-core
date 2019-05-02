class AddColumnImageModeToIllustrations < ActiveRecord::Migration
  def change
  	add_column :illustrations, :image_mode, :boolean, :default => false
  end
end
