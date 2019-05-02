class RemoveStorycardImageFromIllustrationCrops < ActiveRecord::Migration
  def change
    remove_attachment :illustration_crops, :storycard_image
  end
end
