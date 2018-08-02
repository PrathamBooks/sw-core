class AddPartnerViewsToIllustrations < ActiveRecord::Migration
  def change
    add_column :illustrations, :partner_views, :json
  end
end
