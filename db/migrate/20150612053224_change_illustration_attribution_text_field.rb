class ChangeIllustrationAttributionTextField < ActiveRecord::Migration
  def change
  	change_column :illustrations, :attribution_text, :text, limit: 500 
  end
end
