class AddColumnOriginUrlToStories < ActiveRecord::Migration
  def change
    add_column :stories, :origin_url, :string
  end
end
