class CreatePartnerStoryReads < ActiveRecord::Migration
  def change
    create_table :partner_story_reads do |t|
      t.string :partner_id, :null => false
      t.string :story_uuid, :null => false
      t.integer :reads, :default => 0
      t.timestamps
    end
  end
end
