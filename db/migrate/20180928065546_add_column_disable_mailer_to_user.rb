class AddColumnDisableMailerToUser < ActiveRecord::Migration
  def change
  	add_column :users, :disable_mailer, :boolean, default: false
  end
end
