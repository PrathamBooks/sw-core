class AddColumnToSmileyRatings < ActiveRecord::Migration
  def change
  	add_column :smiley_ratings, :session_id, :string
  end
end
