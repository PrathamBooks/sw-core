class RemovePublisherId < ActiveRecord::Migration
  def change
  	remove_column :stories, :publisher_id, :integer
  	remove_column :illustrations, :publisher_id, :integer
  end
end
