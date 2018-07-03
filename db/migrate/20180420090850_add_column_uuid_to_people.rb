class AddColumnUuidToPeople < ActiveRecord::Migration
  def change
    add_column :people, :uuid, :string
  end
end
