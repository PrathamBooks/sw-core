class BlogPostsControllerPolicy
  attr_reader :user, :ctrlr

  def initialize(user, ctrlr)
    @user = user
    @ctrlr = ctrlr
  end

  def default
    user && (user.promotion_manager? || user.content_manager?)
  end
end
