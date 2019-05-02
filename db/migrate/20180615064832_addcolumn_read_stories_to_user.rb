class AddcolumnReadStoriesToUser < ActiveRecord::Migration
  def change
  	add_column :users, :read_stories, :string
  end
end
