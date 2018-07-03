class AddEditorFeedbackToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :editor_feedback, :boolean, :default => false
  end
end
