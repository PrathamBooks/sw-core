class AddCachedLikesToStories < ActiveRecord::Migration
  def change
    add_column :stories, :cached_votes_total, :integer, :default => 0
    add_index  :stories, :cached_votes_total
  end
end
