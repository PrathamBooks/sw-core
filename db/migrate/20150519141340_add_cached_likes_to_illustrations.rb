class AddCachedLikesToIllustrations < ActiveRecord::Migration
  def change
    add_column :illustrations, :cached_votes_total, :integer, :default => 0
    add_index  :illustrations, :cached_votes_total
  end
end
