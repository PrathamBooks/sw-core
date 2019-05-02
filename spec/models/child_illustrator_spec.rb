# == Schema Information
#
# Table name: child_illustrators
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  age             :integer
#  illustration_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#
# Indexes
#
#  index_child_illustrators_on_illustration_id  (illustration_id)
#

require 'rails_helper'

RSpec.describe ChildIllustrator, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
