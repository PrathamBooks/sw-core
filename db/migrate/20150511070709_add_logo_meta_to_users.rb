class AddLogoMetaToUsers < ActiveRecord::Migration
  def change
    add_column :users, :logo_meta, :text
  end
end
