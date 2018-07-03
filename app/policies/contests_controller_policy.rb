class ContestsControllerPolicy
  attr_reader :user, :ctrlr

  def initialize(user, ctrlr)
    @user = user
    @ctrlr = ctrlr
  end

  def default
    user.promotion_manager? || user.content_manager?
  end
end