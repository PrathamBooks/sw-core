class AddRegOrgDateToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :org_registration_date, :datetime
  end
end
