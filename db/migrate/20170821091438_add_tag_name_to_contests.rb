class AddTagNameToContests < ActiveRecord::Migration
  def change
    add_column :contests, :tag_name, :string
  end
end
