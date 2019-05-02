class CreateTranslationFeedbacks < ActiveRecord::Migration
  def change
    create_table :translation_feedbacks do |t|
      t.integer :story_id
      t.integer :user_id
      t.integer :feedback

      t.timestamps
    end
  end
end
