class AddColumnOriginUrlToLanguages < ActiveRecord::Migration
  def change
    add_column :languages, :origin_url, :string
  end
end
