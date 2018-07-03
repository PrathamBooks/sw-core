class AddColumnUuidToIllustrations < ActiveRecord::Migration
  def change
    add_column :illustrations, :uuid, :string
  end
end
