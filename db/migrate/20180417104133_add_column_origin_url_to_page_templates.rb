class AddColumnOriginUrlToPageTemplates < ActiveRecord::Migration
  def change
    add_column :page_templates, :origin_url, :string
  end
end
