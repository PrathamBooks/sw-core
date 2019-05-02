# == Schema Information
#
# Table name: user_popups
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class UserPopup < ActiveRecord::Base
  belongs_to :user
end
