class AddChaildCreatedAndDedicationColumnsToStory < ActiveRecord::Migration
  def change
    add_column :stories, :chaild_created, :boolean, default: false
    add_column :stories, :dedication, :string
  end
end
