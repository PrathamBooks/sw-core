class AddColumnBilingualToLanguages < ActiveRecord::Migration
  def change
  	add_column :languages, :bilingual, :boolean, :default => false
  end
end
