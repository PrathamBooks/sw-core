class AddColumnCopyRightHolderIdToIllustrations < ActiveRecord::Migration
  def change
    add_column :illustrations, :copy_right_holder_id, :integer
  end
end
