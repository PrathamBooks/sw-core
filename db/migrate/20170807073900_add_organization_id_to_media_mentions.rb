class AddOrganizationIdToMediaMentions < ActiveRecord::Migration
  def change
    add_column :media_mentions, :organization_id, :integer
  end
end
