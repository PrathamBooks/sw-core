class RemoveClolumIsPhonestory < ActiveRecord::Migration
  def change
  	remove_column :stories, :is_phonestory
  end
end
