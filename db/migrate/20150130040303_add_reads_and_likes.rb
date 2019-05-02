class AddReadsAndLikes < ActiveRecord::Migration
  def change
    add_column :stories, :reads, :integer, default: 0
    add_column :stories, :likes, :integer, default: 0
  end
end
