# == Schema Information
#
# Table name: lists
#
#  id              :integer          not null, primary key
#  title           :string(255)
#  description     :string(1000)
#  user_id         :integer
#  created_at      :datetime
#  updated_at      :datetime
#  organization_id :integer
#  status          :integer          default(0), not null
#  synopsis        :string(750)
#  can_delete      :boolean          default(TRUE)
#  is_default_list :boolean          default(FALSE)
#

require 'rails_helper'

describe List, :type => :model do
  it{ should validate_presence_of(:title) }
  it{ should validate_presence_of(:user) }
end


