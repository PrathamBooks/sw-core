class AddColumnOriginUrlToUsers < ActiveRecord::Migration
  def change
    add_column :users, :origin_url, :string
  end
end
