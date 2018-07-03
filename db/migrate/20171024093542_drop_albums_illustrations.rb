class DropAlbumsIllustrations < ActiveRecord::Migration
  def change
  	drop_join_table :albums, :illustrations 
  end
end
