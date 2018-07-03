# == Schema Information
#
# Table name: users
#
#  id                         :integer          not null, primary key
#  email                      :string(255)      default(""), not null
#  encrypted_password         :string(255)      default(""), not null
#  reset_password_token       :string(255)
#  reset_password_sent_at     :datetime
#  remember_created_at        :datetime
#  sign_in_count              :integer          default(0), not null
#  current_sign_in_at         :datetime
#  last_sign_in_at            :datetime
#  current_sign_in_ip         :inet
#  last_sign_in_ip            :inet
#  confirmation_token         :string(255)
#  confirmed_at               :datetime
#  confirmation_sent_at       :datetime
#  unconfirmed_email          :string(255)
#  type                       :string(255)      default("User"), not null
#  created_at                 :datetime
#  updated_at                 :datetime
#  role                       :integer          not null
#  attribution                :string(1024)
#  bio                        :string(512)
#  logo_file_name             :string(255)
#  logo_content_type          :string(255)
#  logo_file_size             :integer
#  logo_updated_at            :datetime
#  provider                   :string(255)
#  uid                        :string(255)
#  first_name                 :string(255)
#  last_name                  :string(255)
#  flaggings_count            :integer
#  email_preference           :boolean          default(TRUE)
#  logo_meta                  :text
#  organization_id            :integer
#  organization_roles         :string(255)
#  auth_token                 :string(255)
#  website                    :string(255)
#  city                       :string(255)
#  org_registration_date      :datetime
#  tour_status                :boolean          default(FALSE)
#  profile_image_file_name    :string(255)
#  profile_image_content_type :string(255)
#  profile_image_file_size    :integer
#  profile_image_updated_at   :datetime
#  editor_feedback            :boolean          default(FALSE)
#  language_preferences       :string(255)
#  reading_levels             :string(255)
#  site_roles                 :string(255)
#  recommendations            :string(255)
#  locale_preferences         :string(255)
#  offline_book_popup_seen    :boolean          default(FALSE)
#
# Indexes
#
#  index_users_on_auth_token            (auth_token)
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

FactoryGirl.define do

  factory :user do
    sequence(:first_name) { |n| "User#{n}" }
    sequence(:last_name) { |n| "User Last name #{n}" }
    sequence(:email) { |n| "User#{n}@test.com" }
    password 'password'
    confirmed_at Time.now
    email_preference false
  end

  factory :content_manager, class: User do
    sequence(:first_name) { |n| "contentmanager#{n}" }
    sequence(:email) { |n| "contentmanager#{n}@test.com" }
    password 'password'
    role :content_manager
    site_roles 'content_manager'
    confirmed_at Time.now
  end

  factory :user_without_name, class: User do
    first_name ''
    email 'invalid@test.com'
    password 'password'
    role :content_manager
    site_roles 'content_manager'
    confirmed_at Time.now
  end

  factory :admin, class: User do
    sequence(:first_name) { |n| "Admin#{n}" }
    sequence(:email) { |n| "admin#{n}@test.com" }
    password 'password'
    role 'admin'
    site_roles 'admin'
    confirmed_at Time.now
  end

  factory :reviewer, class: User do
    sequence(:first_name) { |n| "Reviewer#{n}" }
    sequence(:email) { |n| "reviewer#{n}@test.com" }
    password 'password'
    role 'reviewer'
    site_roles 'reviewer'
    confirmed_at Time.now
  end
  factory :publisher_org, class: User do
    sequence(:first_name) { |n| "publisher#{n}" }
    sequence(:email) { |n| "publisher#{n}@test.com" }
    password 'password'
    role 'publisher'
    #organization_id
    organization_roles 'publisher'
    logo Rack::Test::UploadedFile.new('spec/photos/logo.png', 'image/png')
    confirmed_at Time.now
  end
end
