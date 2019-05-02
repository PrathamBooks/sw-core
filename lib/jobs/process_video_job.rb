include ApplicationHelper
require 'convert_story'
class Jobs::ProcessVideoJob < Struct.new(:story, :user)
    
  def perform
    credentials =  YAML.load_file("#{Rails.root}/config/fog.yml")
    connection = Fog::Storage.new(credentials.values.first.symbolize_keys!)
    directory = connection.directories.get(Settings.fog.directory)
    save_story_video(story, 1, directory)
    story.upload_to_youtube(directory)
  end

  def before(job)
    Rails.logger.warn "Started video processing for story #{story.to_param}"
    puts story.id
    story.video_status=0
    story.save!
    story.reindex
    UserMailer.delay.started_video_processing(story, user)
  end

  def after(job)
    Rails.logger.warn "Finished video processing for story #{story.to_param}"
  end

  def success(job)
    Rails.logger.warn "Video got generated successfully for #{story.to_param}"
    UserMailer.delay.video_processing_success(story, user)
  end

  def error(job, exception)
    Rails.logger.warn exception
    story.video_status=nil
    story.is_video=false
    story.save!
    story.reindex
    UserMailer.delay.error_in_video_processing(story, user)
  end
 
  def max_attempts
    1
  end

end
