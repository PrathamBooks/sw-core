class AddColumnMoreInfoToStory < ActiveRecord::Migration
  def change
    add_column :stories, :more_info, :string, :limt => 125
  end
end
