class CreateMediaMentions < ActiveRecord::Migration
  def change
    create_table :media_mentions do |t|
      t.integer :blog_post_id
      t.integer :user_id

      t.timestamps
    end
  end
end
