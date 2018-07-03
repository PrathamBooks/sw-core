class AddColumnOrientationToStories < ActiveRecord::Migration
  def change
    add_column :stories, :orientation, :string
  end
end
