# == Schema Information
#
# Table name: phonestories_popups
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  popup_opened :boolean          default(FALSE)
#  created_at   :datetime
#  updated_at   :datetime
#

class PhonestoriesPopup < ActiveRecord::Base
	belongs_to :user
end
