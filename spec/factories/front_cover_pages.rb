# == Schema Information
#
# Table name: front_cover_pages
#
#  id              :integer          not null, primary key
#  story_id        :integer
#  illustration_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#

FactoryGirl.define do
  factory :front_cover_page do
  end

end
