class AddColumnConsentFlagToUser < ActiveRecord::Migration
  def change
  	add_column :users, :consent_flag, :boolean, default: false
  end
end
