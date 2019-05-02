class CreateJoinTableIllustrationsDownloads < ActiveRecord::Migration
  def change
  	create_join_table :illustration_downloads, :illustrations, table_name: :illustrations_downloads do |t|
      t.index [:illustration_download_id, :illustration_id], name: 'illustrations_downloads_index'
    end
  end
end