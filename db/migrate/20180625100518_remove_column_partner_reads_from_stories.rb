class RemoveColumnPartnerReadsFromStories < ActiveRecord::Migration
  def change
    remove_column :stories, :partner_reads
  end
end
