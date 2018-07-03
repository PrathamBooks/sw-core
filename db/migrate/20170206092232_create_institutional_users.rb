class CreateInstitutionalUsers < ActiveRecord::Migration
  def change
    create_table :institutional_users do |t|
      t.integer :user_id
      t.string :location
      t.timestamps
    end
  end
end
