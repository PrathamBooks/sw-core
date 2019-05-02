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

require 'rails_helper'

RSpec.describe IllustrationDownload, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
