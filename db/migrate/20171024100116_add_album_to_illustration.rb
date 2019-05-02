class AddAlbumToIllustration < ActiveRecord::Migration
  def change
  	add_reference :illustrations, :album, index: true
  end
end
