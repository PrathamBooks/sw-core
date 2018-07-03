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

class StoryDownload < ActiveRecord::Base

  belongs_to :user
  belongs_to :organization
  has_and_belongs_to_many :stories, join_table: 'stories_downloads'

  validate :user, presence: true
  #validate :story, presence: true


  def download_format
   if self.download_type == "high"
   	return "High"
   elsif self.download_type == "low"
   	return "Low"
   elsif self.download_type == "epub"
   	return "Epub"
   elsif self.download_type == "images_only"
   	return "Images"
   elsif self.download_type == "text_only"
   	return "Text"
   end
  end

end
