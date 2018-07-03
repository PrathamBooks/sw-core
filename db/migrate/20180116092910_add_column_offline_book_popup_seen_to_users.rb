class AddColumnOfflineBookPopupSeenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :offline_book_popup_seen, :boolean, :default => false
  end
end
