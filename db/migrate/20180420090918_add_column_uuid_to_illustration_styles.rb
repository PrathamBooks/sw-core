class AddColumnUuidToIllustrationStyles < ActiveRecord::Migration
  def change
    add_column :illustration_styles, :uuid, :string
  end
end
