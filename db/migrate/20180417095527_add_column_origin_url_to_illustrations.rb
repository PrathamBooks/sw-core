class AddColumnOriginUrlToIllustrations < ActiveRecord::Migration
  def change
    add_column :illustrations, :origin_url, :string
  end
end
