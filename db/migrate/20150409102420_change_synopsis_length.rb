class ChangeSynopsisLength < ActiveRecord::Migration
  def change
  	change_column :stories, :synopsis, :string, null: true, limit: 750 
  end
end
