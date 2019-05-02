class CreateJoinTableListCategoriesLists < ActiveRecord::Migration
  def change
    create_join_table :list_categories, :lists do |t|
      t.index [:list_category_id, :list_id],name: 'category_list_index'
    end
  end
end
