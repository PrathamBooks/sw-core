class AddLicenseTypeToStory < ActiveRecord::Migration
  def change
  	add_column :stories, :license_type, :string, default: 'CC BY 4.0'
  end
end
