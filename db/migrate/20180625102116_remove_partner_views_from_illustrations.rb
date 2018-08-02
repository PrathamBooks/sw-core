class RemovePartnerViewsFromIllustrations < ActiveRecord::Migration
  def change
    remove_column :illustrations, :partner_views
  end
end
