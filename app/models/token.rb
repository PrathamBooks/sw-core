# == Schema Information
#
# Table name: tokens
#
#  id                          :integer          not null, primary key
#  access_token                :string(255)      not null
#  story_count                 :integer          default(0)
#  illustration_count          :integer          default(0)
#  organization_id             :integer          not null
#  expires_at                  :datetime
#  created_at                  :datetime
#  updated_at                  :datetime
#  story_download_limit        :integer          default(0)
#  illustration_download_limit :integer          default(0)
#


class Token < ActiveRecord::Base
  belongs_to :organization

  attr_reader :valid_for

  def valid_for=(day_count)
    self.expires_at = Time.now + (day_count.to_i).days
  end
end
