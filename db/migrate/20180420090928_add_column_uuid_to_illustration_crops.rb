class AddColumnUuidToIllustrationCrops < ActiveRecord::Migration
  def change
    add_column :illustration_crops, :uuid, :string
  end
end
