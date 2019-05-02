class AddCopyRightYearToIllustrations < ActiveRecord::Migration
  def change
    add_column :illustrations, :copy_right_year, :integer
  end
end
