class AddMessagesColumnsToStory < ActiveRecord::Migration
  def change
    add_column :stories, :publish_message, :text
    add_column :stories, :download_message, :text
  end
end
