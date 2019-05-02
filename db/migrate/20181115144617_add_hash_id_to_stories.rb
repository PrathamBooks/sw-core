class AddHashIdToStories < ActiveRecord::Migration
  def change
    add_column :stories, :hash_id, :string
  end
end
