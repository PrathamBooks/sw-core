class AddColumnPublisherToIllustrations < ActiveRecord::Migration
  def change
    add_column :illustrations, :publisher_id, :integer
  end
end
