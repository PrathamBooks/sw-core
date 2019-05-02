class ChangeColumnsToAlbum < ActiveRecord::Migration
  def change
    change_table :albums do |t|
  	  t.remove :organization_id, :user_id
  	  t.string :title
  	  t.integer :story_id	

  	end
  end
end
