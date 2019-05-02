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

require 'rails_helper'

RSpec.describe Youngster, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
