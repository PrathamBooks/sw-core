class AddColumnUuidToPageTemplates < ActiveRecord::Migration
  def change
    add_column :page_templates, :uuid, :string
  end
end
