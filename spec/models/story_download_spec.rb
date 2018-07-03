# == Schema Information
#
# Table name: story_downloads
#
#  id                :integer          not null, primary key
#  user_id           :integer          not null
#  story_id          :integer          not null
#  download_type     :string(255)
#  ip_address        :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  organization_user :boolean          default(FALSE)
#  org_id            :integer
#  list_id           :integer
#
# Indexes
#
#  index_story_downloads_on_story_id_and_user_id  (story_id,user_id)
#

require 'rails_helper'

RSpec.describe StoryDownload, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
