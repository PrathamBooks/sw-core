class AddColumnTypeToPageTemplate < ActiveRecord::Migration
  def change
    add_column :page_templates, :type, :string
  end
end
