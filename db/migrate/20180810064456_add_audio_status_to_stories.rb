class AddAudioStatusToStories < ActiveRecord::Migration
  def change
    add_column :stories, :audio_status, :integer
  end
end
