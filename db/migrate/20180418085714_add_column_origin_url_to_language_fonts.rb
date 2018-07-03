class AddColumnOriginUrlToLanguageFonts < ActiveRecord::Migration
  def change
    add_column :language_fonts, :origin_url, :string
  end
end
