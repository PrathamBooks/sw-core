# == Schema Information
#
# Table name: footer_images
#
#  id              :integer          not null, primary key
#  illustration_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#

class FooterImage < ActiveRecord::Base
  belongs_to :illustration
end
