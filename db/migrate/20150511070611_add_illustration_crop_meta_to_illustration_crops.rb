class AddIllustrationCropMetaToIllustrationCrops < ActiveRecord::Migration
  def change
    add_column :illustration_crops, :image_meta, :text
  end
end
