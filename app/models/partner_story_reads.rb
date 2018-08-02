# == Schema Information
#
# Table name: partner_story_reads
#
#  id         :integer          not null, primary key
#  partner_id :string(255)      not null
#  story_uuid :string(255)      not null
#  reads      :integer          default(0)
#  created_at :datetime
#  updated_at :datetime
#

class PartnerStoryReads < ActiveRecord::Base
end
