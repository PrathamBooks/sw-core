class CreateImportPartners < ActiveRecord::Migration
  def change
    create_table :import_partners do |t|
      t.string :attribution_name, :null => false
      t.string :url, :null => false
      t.string :prefix, :null => false
      t.belongs_to :organization
      t.timestamps
    end
  end
end
