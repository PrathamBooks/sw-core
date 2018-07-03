class AddSentMailsColumnToFlaggings < ActiveRecord::Migration
  def change
  	add_column :flaggings, :sent_mails, :boolean, default: false
  end
end
