class RenameColumnInPartnerIllustrationViews < ActiveRecord::Migration
  def change
    remove_column :partner_illustration_views, :partner_id
    add_reference :partner_illustration_views, :organization
  end
end
