class AddColumnUuidToStories < ActiveRecord::Migration
  def change
    add_column :stories, :uuid, :string
  end
end
