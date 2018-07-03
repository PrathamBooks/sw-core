class StoryPolicy
 attr_reader :user, :story

  def initialize(user, story)
    @user = user
    @story = story
  end

  def show?
    read_access
  end

  def edit?
    default_access
  end

  # For uploaded stories organization is non-null
  # Content manager can always edit
  # For uploaded story the organization can always edit, reviewer can only edit before it is published
  # authors cannot edit
  # For user created stories, authors can always edit
  def editable?
    return true if user.content_manager?
    if story.submitted?
      return false
    elsif user.organization?
      return true if user.organization == story.organization
    end
    return story.editor == user if story.uploaded?
    return story.authors.include?(user)
    false
  end

  def download_type?(type)
    if type == "PDF" || type == "epub"
      return true
    elsif type == "HiRes PDF"
      if user.content_manager? || (user.organization? && user.organization == story.organization)
        return true
      elsif (story.authors.collect(&:email).join(",") == story.illustrators.collect(&:email).join(",") && story.authors.collect(&:email).join(",") == user.email)
        return true
      end
    end
  end

  def share_and_translate?
    if story.de_activated?
      if story.authors.include?(user)
        return false
      elsif user.content_manager?
        return true
      end
    elsif story.submitted?
      default_access
    else
      return true
    end
  end

  def download?
    if story.submitted?
      default_access
    else
      return true
    end
  end

  def flag?
    if story.published? && !story.flagged?
      return true
    end
    false
  end

  def is_active?
    if user
     active_story_access
    else
      if story.published?
        return true
      else
        false
      end
    end
  end

  def editor_assignable?
    if((user && user.content_manager?) && (story.organization.present? && !story.published?))
      return true
    else
      return false
    end
  end

  def publish?
    publish_access
  end

  private
  def default_access
    if story.draft? || story.edit_in_progress?
      return user.content_manager? || story.authors.include?(user) || (user.organization? && user.organization == story.organization)
    elsif story.uploaded?
      return story.editor == user || user.content_manager? || (user.organization? && user.organization == story.organization)
    elsif story.de_activated?
      return user.content_manager? || story.authors.include?(user)
    elsif story.submitted?
      return user.promotion_manager?  || user.content_manager?
    end
    false
  end

  def read_access
    if story.draft? || story.edit_in_progress?
      return user.content_manager? || story.authors.include?(user) || (user.organization? && user.organization == story.organization)
    elsif story.uploaded?
      return story.editor == user || user.content_manager? || (user.organization? && user.organization == story.organization)
    elsif story.de_activated?
      return user.content_manager? || story.authors.include?(user)
    elsif story.submitted?
      return user.promotion_manager?  || user.content_manager? || story.authors.include?(user)
    elsif story.publish_pending?
      return false
    end
    true
  end

  def publish_access
    if story.draft? || story.uploaded? || story.edit_in_progress? || story.de_activated? || story.publish_pending? || story.submitted?
      return user.content_manager? || story.authors.include?(user) || (user.organization? && user.organization == story.organization)
    else 
      false
    end
  end

  def active_story_access
    if story.draft? || story.edit_in_progress? 
      return user.content_manager? || story.authors.include?(user) || (user.organization? && user.organization == story.organization)
    elsif story.uploaded?
      return story.editor == user || user.content_manager? || story.authors.include?(user) || (user.organization? && user.organization == story.organization)
    elsif story.de_activated?
      return user.content_manager? || story.authors.include?(user)
    elsif story.published?
      return true
    elsif story.submitted?
      return user.promotion_manager? || user.content_manager? || story.authors.include?(user)
    else
      return false
    end
  end
end
