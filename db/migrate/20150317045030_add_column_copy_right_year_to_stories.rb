class AddColumnCopyRightYearToStories < ActiveRecord::Migration
  def change
    add_column :stories, :copy_right_year, :integer
  end
end
