class AddColumnOriginUrlToIllustrationCrops < ActiveRecord::Migration
  def change
    add_column :illustration_crops, :origin_url, :string
  end
end
