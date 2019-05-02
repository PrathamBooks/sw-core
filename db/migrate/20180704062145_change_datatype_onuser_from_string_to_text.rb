class ChangeDatatypeOnuserFromStringToText < ActiveRecord::Migration
  def change
  	change_column :users, :read_stories, :text
  end
end
