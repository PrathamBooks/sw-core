class ChangeAttributionTextCharacterLimit < ActiveRecord::Migration
  def change
  	change_column :stories, :attribution_text, :text, limit: 1000 
  end
end
