class AddLicenseTypeToIllustrations < ActiveRecord::Migration
  def change
    add_column :illustrations, :license_type, :integer
  end
end
