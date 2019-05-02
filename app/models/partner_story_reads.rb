# == Schema Information
#
# Table name: partner_story_reads
#
#  id              :integer          not null, primary key
#  story_uuid      :string(255)      not null
#  reads           :integer          default(0)
#  created_at      :datetime
#  updated_at      :datetime
#  organization_id :integer
#


class PartnerStoryReads < ActiveRecord::Base
  belongs_to :organization
end
