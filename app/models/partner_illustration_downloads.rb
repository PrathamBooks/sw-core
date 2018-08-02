# == Schema Information
#
# Table name: partner_illustration_downloads
#
#  id                :integer          not null, primary key
#  partner_id        :string(255)      not null
#  illustration_uuid :string(255)      not null
#  downloads         :integer          default(0)
#  created_at        :datetime
#  updated_at        :datetime
#

class PartnerIllustrationDownloads < ActiveRecord::Base
end
