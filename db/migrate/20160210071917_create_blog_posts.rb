class CreateBlogPosts < ActiveRecord::Migration
  def change
    create_table :blog_posts do |t|
      t.string :title
      t.text :body
      t.integer :status
      t.datetime :scheduled
      t.integer :comments_count
      t.integer :user_id

      t.timestamps
    end
  end
end
