class CreateLanguageFonts < ActiveRecord::Migration
  def change
    create_table :language_fonts do |t|
      t.string :font
      t.string :script

      t.timestamps
    end
    add_column :languages, :language_font_id, :integer

  end
end
