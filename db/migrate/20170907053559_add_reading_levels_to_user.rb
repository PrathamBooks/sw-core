class AddReadingLevelsToUser < ActiveRecord::Migration
  def change
  	add_column :users, :reading_levels, :string
  end
end
