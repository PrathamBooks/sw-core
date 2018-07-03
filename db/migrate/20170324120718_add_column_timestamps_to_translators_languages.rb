class AddColumnTimestampsToTranslatorsLanguages < ActiveRecord::Migration
  def change
  	 add_column :translators_languages, :created_at, :datetime
  	 add_column :translators_languages, :updated_at, :datetime
  end
end
