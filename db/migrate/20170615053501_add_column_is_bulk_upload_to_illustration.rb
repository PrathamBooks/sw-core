class AddColumnIsBulkUploadToIllustration < ActiveRecord::Migration
  def change
    add_column :illustrations, :is_bulk_upload, :boolean, default: false
  end
end
