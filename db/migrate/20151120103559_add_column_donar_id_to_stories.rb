class AddColumnDonarIdToStories < ActiveRecord::Migration
  def change
    add_column :stories, :donar_id, :integer
    add_column :stories, :copy_right_holder_id, :integer
  end
end
