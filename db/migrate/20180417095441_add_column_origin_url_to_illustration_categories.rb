class AddColumnOriginUrlToIllustrationCategories < ActiveRecord::Migration
  def change
    add_column :illustration_categories, :origin_url, :string
  end
end
