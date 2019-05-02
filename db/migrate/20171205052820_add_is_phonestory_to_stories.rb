class AddIsPhonestoryToStories < ActiveRecord::Migration
  def change
  	add_column :stories, :is_phonestory, :boolean, :default => false
  end
end
