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

FactoryGirl.define do
	factory :donor do
		name "Test donor"
		logo Rack::Test::UploadedFile.new('spec/photos/forest.jpg', 'image/jpg')
	end
end
