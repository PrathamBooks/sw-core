class AddColumnUuidToLanguages < ActiveRecord::Migration
  def change
    add_column :languages, :uuid, :string
  end
end
