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
    content             'Front Cover'
    position            1
    story_id            2
    type                'FrontCoverPage'
    page_template       {FactoryGirl.create(:page_template)}
  end

end
