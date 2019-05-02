# == Schema Information
#
# Table name: user_tokens
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  token      :string(255)
#  email_sent :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#

class UserToken < ActiveRecord::Base
	belongs_to :user
end
