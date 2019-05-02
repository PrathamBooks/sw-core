class ChangeSynopsisCharcterLimitation < ActiveRecord::Migration
  def change
  	change_column :stories, :synopsis, :string, null: true, limit: 500 
  end
end
