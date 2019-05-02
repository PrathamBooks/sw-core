class AddColumnPartnerReadsToStories < ActiveRecord::Migration
  def change
    add_column :stories, :partner_reads, :json
  end
end
