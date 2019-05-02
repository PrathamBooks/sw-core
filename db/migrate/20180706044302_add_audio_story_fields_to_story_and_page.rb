class AddAudioStoryFieldsToStoryAndPage < ActiveRecord::Migration
  def change
    add_column :stories, :is_audio, :boolean, default: false
    add_column :pages, :audio_content, :text
  end
end
