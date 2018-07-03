class AddColumnsToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :facebook_url, :string
    add_column :organizations, :rss_url, :string
    add_column :organizations, :twitter_url, :string
    add_column :organizations, :youtube_url, :string
  end
end
