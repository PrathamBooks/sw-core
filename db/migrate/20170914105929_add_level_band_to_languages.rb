class AddLevelBandToLanguages < ActiveRecord::Migration
  def change
    add_column :languages, :level_band, :string
  end
end
