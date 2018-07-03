class AddOrgCopyRightHolderToIllustration < ActiveRecord::Migration
  def change
  	add_column :illustrations, :org_copy_right_holder_id, :integer
  end
end
