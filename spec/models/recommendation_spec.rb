# == Schema Information
#
# Table name: recommendations
#
#  id                 :integer          not null, primary key
#  recommendable_id   :integer
#  recommendable_type :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#

require 'rails_helper'

RSpec.describe Recommendation, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
