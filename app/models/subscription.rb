# == Schema Information
#
# Table name: subscriptions
#
#  id         :integer          not null, primary key
#  email      :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#

class Subscription < ActiveRecord::Base

  validates_format_of :email,:with => /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/
  
  after_create :subscribe_user_to_mailing_list

  def subscribe_user_to_mailing_list
    if Rails.env == 'production'
      SubscribeUserToMailingListJob.perform_later(self)
    end
  end
end
