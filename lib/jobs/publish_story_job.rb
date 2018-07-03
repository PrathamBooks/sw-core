class Jobs::PublishStoryJob < Struct.new(:story_id)
  def perform
    story = Story.find_by(id: story_id)
    if story.nil?
      return
    elsif !story.pending_illustration_uploads?
      story.publish
    else
      Delayed::Job.enqueue self, 0, DateTime.now.utc + Settings.story.republish_interval.to_i.minutes
    end
  end
  def queue_name
    'story_publish'
  end
end

