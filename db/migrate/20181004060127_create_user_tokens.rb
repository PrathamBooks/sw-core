class CreateUserTokens < ActiveRecord::Migration
  def change
    create_table :user_tokens do |t|
      t.integer :user_id
      t.string :token
      t.boolean :email_sent, default: false

      t.timestamps
    end
  end
end
