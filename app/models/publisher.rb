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

class Publisher < User
  def initialize(attributes = nil)
    super(attributes)
    self.role = :publisher
  end

  def has_recommended_right?
  	true
  end

  # validates :attribution, presence: true, length: {maximum: 1024}

end
