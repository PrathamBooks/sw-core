# == Schema Information
#
# Table name: organizations
#
#  id                   :integer          not null, primary key
#  organization_name    :string(255)
#  organization_type    :string(255)
#  country              :string(255)
#  city                 :string(255)
#  number_of_classrooms :integer
#  children_impacted    :integer
#  status               :string(255)
#  logo_file_name       :string(255)
#  logo_content_type    :string(255)
#  logo_file_size       :integer
#  logo_updated_at      :datetime
#  created_at           :datetime
#  updated_at           :datetime
#  description          :string(1000)
#  email                :string(255)
#  website              :string(255)
#  facebook_url         :string(255)
#  rss_url              :string(255)
#  twitter_url          :string(255)
#  youtube_url          :string(255)
#
# Indexes
#
#  index_organizations_on_email  (email)
#

FactoryGirl.define do
  factory :organization do
    sequence(:organization_name) { |n| "organization_name #{n}" }
    sequence(:country) {|n| "country #{n}"}
    sequence(:city) { |n| "city #{n}" }
    sequence(:number_of_classrooms) { |n| "number_of_classrooms #{n}" }
    sequence(:children_impacted) { |n| "children_impacted#{n}" }
    organization_type 'null'
    status 'Approved'
    website 'www.storyweaver.org'
  end

  factory :org_publisher, class: Organization do
    sequence(:organization_name) { |n| "org_publisher_name #{n}" }
    sequence(:country) {|n| "country #{n}"}
    sequence(:city) { |n| "city #{n}" }
    number_of_classrooms 10
    children_impacted 10
    organization_type 'Publisher'
    status 'Approved'
    website 'www.storyweaver.org'
  end
end

