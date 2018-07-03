class IncreaseLimitForOrgDescription < ActiveRecord::Migration
  def change
  	change_column :organizations, :description, :string, :limit => 1000
  end
end
