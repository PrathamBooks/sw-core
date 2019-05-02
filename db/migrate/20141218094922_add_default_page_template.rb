class AddDefaultPageTemplate < ActiveRecord::Migration
  def change
  	add_column :page_templates, :default, :boolean, default: false
  end
end
