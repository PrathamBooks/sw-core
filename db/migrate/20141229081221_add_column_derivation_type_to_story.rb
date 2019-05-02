class AddColumnDerivationTypeToStory < ActiveRecord::Migration
  def change
  	 add_column :stories, :derivation_type, :string 
  end
end
