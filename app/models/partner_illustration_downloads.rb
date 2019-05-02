# == Schema Information
#
# Table name: partner_illustration_downloads
#
#  id                :integer          not null, primary key
#  illustration_uuid :string(255)      not null
#  downloads         :integer          default(0)
#  created_at        :datetime
#  updated_at        :datetime
#  organization_id   :integer
#


class PartnerIllustrationDownloads < ActiveRecord::Base
  belongs_to :organization
end
