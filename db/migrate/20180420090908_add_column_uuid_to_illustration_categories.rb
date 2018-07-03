class AddColumnUuidToIllustrationCategories < ActiveRecord::Migration
  def change
    add_column :illustration_categories, :uuid, :string
  end
end
