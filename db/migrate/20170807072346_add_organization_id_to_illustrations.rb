class AddOrganizationIdToIllustrations < ActiveRecord::Migration
  def change
    add_column :illustrations, :organization_id, :integer
  end
end
