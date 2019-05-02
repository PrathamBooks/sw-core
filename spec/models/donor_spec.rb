# == Schema Information
#
# Table name: donors
#
#  id                :integer          not null, primary key
#  name              :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  logo_file_name    :string(255)
#  logo_content_type :string(255)
#  logo_file_size    :integer
#  logo_updated_at   :datetime
#

require 'rails_helper'

RSpec.describe Donor, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
