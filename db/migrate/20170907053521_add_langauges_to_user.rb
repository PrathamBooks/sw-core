class AddLangaugesToUser < ActiveRecord::Migration
  def change
  	add_column :users, :language_preferences, :string
  end
end
