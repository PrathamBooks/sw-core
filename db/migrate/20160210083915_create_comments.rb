class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.references :blog_post, index: true
      t.text :body
      t.integer :user_id

      t.timestamps
    end
  end
end
