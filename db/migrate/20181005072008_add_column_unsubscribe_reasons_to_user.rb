class AddColumnUnsubscribeReasonsToUser < ActiveRecord::Migration
  def change
  	add_column :users, :unsubscribe_reasons, :text, :limit => nil
  end
end
