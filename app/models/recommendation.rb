# == Schema Information
#
# Table name: recommendations
#
#  id                 :integer          not null, primary key
#  recommendable_id   :integer
#  recommendable_type :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#

class Recommendation < ActiveRecord::Base
  belongs_to :recommendable, :polymorphic => true

  after_commit :clear_cache

  #After create or destroy a recommendation clearing cache.
  def clear_cache
    Rails.cache.delete('content_manager_recommendation')
  end
end
