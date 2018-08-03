# == Schema Information
#
# Table name: partner_illustration_views
#
#  id                :integer          not null, primary key
#  partner_id        :string(255)      not null
#  illustration_uuid :string(255)      not null
#  views             :integer          default(0)
#  created_at        :datetime
#  updated_at        :datetime
#

class PartnerIllustrationViews < ActiveRecord::Base
  belongs_to :organization
end
