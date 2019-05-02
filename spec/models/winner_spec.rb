# == Schema Information
#
# Table name: winners
#
#  id         :integer          not null, primary key
#  story_id   :integer
#  contest_id :integer
#  story_type :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe Winner, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
