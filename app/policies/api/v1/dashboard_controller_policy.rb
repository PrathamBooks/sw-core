class Api::V1::DashboardControllerPolicy
  attr_reader :user, :ctrlr

  def initialize(user, ctrlr)
    @user = user
    @ctrlr = ctrlr
  end

  def default
    user.content_manager?
  end
end
