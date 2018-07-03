class IllustrationPolicy
 attr_reader :user, :illustration

  def initialize(user, illustration)
    @user = user
    @illustration = illustration
  end

  def flag?
    illustration.flagged? ? false : true
  end

  def view?
    view_access
  end

  def download_type?(type)
    if type == "JPEG"
      return true
    elsif type == "HiRes JPEG"
      return true if user.content_manager? || illustration.illustrators.collect(&:email).include?(user.email) || (user.organization? && user.organization == illustration.organization)
    end
  end

  def view_access
    if illustration.is_pulled_down?
      return user.content_manager?
    elsif illustration.image_mode
      return user.content_manager? || illustration.illustrators.collect(&:user_id).include?(user.id)
    else
      return true
    end
  end
end
