class CreateJoinTableIllustrationCategoriesIllustrations < ActiveRecord::Migration
  def change
    create_join_table :illustration_categories, :illustrations do |t|
      t.index [:illustration_category_id, :illustration_id],name: 'category_illustration_index'
    end
  end
end
