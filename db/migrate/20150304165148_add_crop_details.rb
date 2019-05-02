class AddCropDetails < ActiveRecord::Migration
  def change
    add_column :illustration_crops,:crop_details,:text
  end
end
