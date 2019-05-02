class AddDownloadLimitCountersToToken < ActiveRecord::Migration
  def change
    add_column :tokens, :story_download_limit, :integer, default: 0
    add_column :tokens, :illustration_download_limit, :integer, default: 0
  end
end
