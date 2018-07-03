class IncreaseLimitForListDescription < ActiveRecord::Migration
  def change
  	change_column :lists, :description, :string, :limit => 1000
  end
end
