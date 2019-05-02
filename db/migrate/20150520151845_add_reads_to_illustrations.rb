class AddReadsToIllustrations < ActiveRecord::Migration
  def change
    add_column :illustrations, :reads, :integer, default: 0
  end
end
