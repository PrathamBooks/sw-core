# == Schema Information
#
# Table name: import_partners
#
#  id               :integer          not null, primary key
#  attribution_name :string(255)      not null
#  url              :string(255)      not null
#  prefix           :string(255)      not null
#  organization_id  :integer
#  created_at       :datetime
#  updated_at       :datetime
#

class ImportPartner < ActiveRecord::Base
  belongs_to :organization
  has_many :stories
end
