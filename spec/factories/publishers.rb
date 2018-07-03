# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  name                   :string(255)      default(""), not null
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string(255)
#  type                   :string(255)      default("User"), not null
#  created_at             :datetime
#  updated_at             :datetime
#  role                   :integer          not null
#  attribution            :string(1024)
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

FactoryGirl.define do

  factory :publisher do
    sequence(:name) { |n| "Publisher #{n}" }
    sequence(:email) { |n| "Publisher#{n}@test.com" }
    password 'password'
    attribution "This content is attributed to Publisher."
    logo Rack::Test::UploadedFile.new('spec/photos/logo.png', 'image/png')
    confirmed_at Time.now
  end

end
