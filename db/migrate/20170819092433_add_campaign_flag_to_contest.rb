class AddCampaignFlagToContest < ActiveRecord::Migration
  def change
    add_column :contests, :is_campaign, :boolean, default: false
  end
end
