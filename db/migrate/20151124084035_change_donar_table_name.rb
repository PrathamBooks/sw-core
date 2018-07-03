class ChangeDonarTableName < ActiveRecord::Migration
  def change
    rename_table :donars, :donors
    rename_column :stories, :donar_id, :donor_id
  end
end
