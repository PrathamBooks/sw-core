# == Schema Information
#
# Table name: people
#
#  id                      :integer          not null, primary key
#  user_id                 :integer
#  created_at              :datetime
#  updated_at              :datetime
#  created_by_publisher_id :integer
#  first_name              :string(255)
#  last_name               :string(255)
#
# Indexes
#
#  index_people_on_created_by_publisher_id  (created_by_publisher_id)
#

require 'rails_helper'

RSpec.describe Person, :type => :model do
  it { should validate_presence_of :first_name }
  it { should ensure_length_of(:first_name).is_at_least(2) }
  it { should ensure_length_of(:first_name).is_at_most(255) }
end
