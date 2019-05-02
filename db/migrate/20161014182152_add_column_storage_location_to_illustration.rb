class AddColumnStorageLocationToIllustration < ActiveRecord::Migration
  def change
    add_column :illustrations, :storage_location, :string
    add_column :illustration_crops, :storage_location, :string
  end
end
