class CreateJoinTableIllustrationStylesIllustrations < ActiveRecord::Migration
  def change
    create_join_table :illustration_styles, :illustrations do |t|
      t.index [:illustration_style_id, :illustration_id], name: "style_illustration_index"
      t.index [:illustration_id, :illustration_style_id], name: "illustration_style_index"

    end
  end
end
