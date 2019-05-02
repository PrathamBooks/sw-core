class AddSynopsisColumnToLists < ActiveRecord::Migration
  def change
    add_column :lists, :synopsis, :string, limit: 750
  end
end
