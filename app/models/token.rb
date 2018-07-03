# == Schema Information
#
# Table name: tokens
#
#  id                 :integer          not null, primary key
#  access_token       :string(255)      not null
#  story_count        :integer          default(0)
#  illustration_count :integer          default(0)
#  organization_id    :integer          not null
#  expires_at         :datetime
#  created_at         :datetime
#  updated_at         :datetime
#

class Token < ActiveRecord::Base
end
