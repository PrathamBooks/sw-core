class DashboardControllerPolicy
  attr_reader :user, :ctrlr

  def initialize(user, ctrlr)
    @user = user
    @ctrlr = ctrlr
  end

  def default
    user.content_manager?
  end

  def analytics
  	user.content_manager? || user.outreach_manager?
  end

end
