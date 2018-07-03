class AddColumnUuidToLanguageFonts < ActiveRecord::Migration
  def change
    add_column :language_fonts, :uuid, :string
  end
end
