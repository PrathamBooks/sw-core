# == Schema Information
#
# Table name: piwik_events
#
#  id         :integer          not null, primary key
#  category   :string(255)      not null
#  action     :string(255)      not null
#  name       :string(255)
#  value      :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe PiwikEvent, :type => :model do
  it { should validate_presence_of :category }
  it { should validate_presence_of :action }
  it { should_not validate_presence_of :name }
  it { should_not validate_presence_of :value }
end
