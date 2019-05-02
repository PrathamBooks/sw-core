class ListPolicy
  attr_reader :user, :list

  def initialize(user, list)
    @user = user
    @list = list
  end

  def update?
    default_access
  end

  def destroy?
    default_access
  end

  def add_story?
    default_access
  end

  def remove_story?
    default_access
  end

  def rearrange_story?
    default_access
  end

  private
  def default_access
    list.user == user || user.content_manager?
  end
end