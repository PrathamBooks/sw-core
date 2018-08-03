class RenameColumnInPartnerStoryReads < ActiveRecord::Migration
  def change
    remove_column :partner_story_reads, :partner_id
    add_reference :partner_story_reads, :organization
  end
end
