class CreateJoinTableAlbumUser < ActiveRecord::Migration
  def change
  	create_join_table :albums, :users do |t|
      t.index [:album_id, :user_id]
      t.index [:user_id, :album_id]
    end
  end
end
