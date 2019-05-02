class AddDummyDraftColumToStory < ActiveRecord::Migration
  def change
    add_column :stories, :dummy_draft, :boolean, default: true
  end
end
