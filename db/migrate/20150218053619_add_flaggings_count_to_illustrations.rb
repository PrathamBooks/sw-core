class AddFlaggingsCountToIllustrations < ActiveRecord::Migration
  def change
    add_column :illustrations, :flaggings_count, :integer
  end
end
