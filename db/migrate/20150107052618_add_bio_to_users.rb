class AddBioToUsers < ActiveRecord::Migration
  def change
    add_column :users, :bio, :string, limit: 512
  end
end
