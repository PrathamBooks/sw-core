# == Schema Information
#
# Table name: illustration_downloads
#
#  id              :integer          not null, primary key
#  user_id         :integer          not null
#  illustration_id :integer          not null
#  download_type   :string(255)
#  ip_address      :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#
# Indexes
#
#  index_illustration_downloads_on_user_id_and_illustration_id  (user_id,illustration_id)
#

FactoryGirl.define do
  factory :illustration_download do
    
  end

end
