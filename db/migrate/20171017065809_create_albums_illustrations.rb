class CreateAlbumsIllustrations < ActiveRecord::Migration
  def change
    create_table :albums_illustrations, id: false do |t|
    	t.belongs_to :album
    	t.belongs_to :illustration
    end
  end
end
