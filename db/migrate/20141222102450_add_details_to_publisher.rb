class AddDetailsToPublisher < ActiveRecord::Migration
  def change
    add_column :users, :attribution, :string, null: true, limit: 1024
  end
end
