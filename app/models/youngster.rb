# == Schema Information
#
# Table name: youngsters
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  age        :integer
#  story_id   :integer
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_youngsters_on_story_id  (story_id)
#

class Youngster < ActiveRecord::Base
  belongs_to :story

end
