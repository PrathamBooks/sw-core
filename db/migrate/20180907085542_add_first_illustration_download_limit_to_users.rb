class AddFirstIllustrationDownloadLimitToUsers < ActiveRecord::Migration
  def change
    add_column :users, :first_illustration_download_limit, :boolean, default: false
  end
end
