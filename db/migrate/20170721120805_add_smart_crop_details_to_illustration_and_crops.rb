class AddSmartCropDetailsToIllustrationAndCrops < ActiveRecord::Migration
  def change
    add_column :illustration_crops, :smart_crop_details, :text
    add_column :illustrations, :smart_crop_details, :text
  end
end
