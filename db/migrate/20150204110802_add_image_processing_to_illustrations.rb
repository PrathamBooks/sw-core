class AddImageProcessingToIllustrations < ActiveRecord::Migration
  def change
    add_column :illustrations, :image_processing, :boolean
  end
end
