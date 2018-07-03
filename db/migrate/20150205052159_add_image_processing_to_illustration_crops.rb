class AddImageProcessingToIllustrationCrops < ActiveRecord::Migration
  def change
    add_column :illustration_crops, :image_processing, :boolean
  end
end
