class ChangeCloumnScheduled < ActiveRecord::Migration
  def change
    change_column :blog_posts, :scheduled, :datetime
  end
end
