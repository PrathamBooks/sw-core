# == Schema Information
#
# Table name: partner_story_downloads
#
#  id                     :integer          not null, primary key
#  story_uuid             :string(255)      not null
#  total_downloads        :integer          default(0)
#  epub_downloads         :integer          default(0)
#  low_res_pdf_downloads  :integer          default(0)
#  high_res_pdf_downloads :integer          default(0)
#  created_at             :datetime
#  updated_at             :datetime
#  organization_id        :integer
#


class PartnerStoryDownloads < ActiveRecord::Base
  belongs_to :organization
end
