class AddColumnOriginUrlToIllustrationStyles < ActiveRecord::Migration
  def change
    add_column :illustration_styles, :origin_url, :string
  end
end
