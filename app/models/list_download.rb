# == Schema Information
#
# Table name: list_downloads
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  list_id    :integer          not null
#  when       :datetime
#  ip_address :string(255)
#
# Indexes
#
#  index_list_downloads_on_user_id_and_list_id  (user_id,list_id)
#

class ListDownload < ActiveRecord::Base
  belongs_to :list
  belongs_to :user

  validate :user, presence: true
  validate :list, presence: true
end
