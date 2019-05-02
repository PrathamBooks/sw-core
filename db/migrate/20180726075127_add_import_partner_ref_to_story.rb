class AddImportPartnerRefToStory < ActiveRecord::Migration
  def change
    add_reference :stories, :import_partner
  end
end
