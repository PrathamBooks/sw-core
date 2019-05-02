class UpdateLanguagesAddScript < ActiveRecord::Migration
  def change
    add_column :languages, :script, :string
  end
end
