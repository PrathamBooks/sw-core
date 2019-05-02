class AddColumnOriginUrlToPeople < ActiveRecord::Migration
  def change
    add_column :people, :origin_url, :string
  end
end
