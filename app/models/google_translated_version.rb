# == Schema Information
#
# Table name: google_translated_versions
#
#  id                        :integer          not null, primary key
#  page_id                   :integer
#  google_translated_content :text
#  created_at                :datetime
#  updated_at                :datetime
#

class GoogleTranslatedVersion < ActiveRecord::Base
  belongs_to :page
end
