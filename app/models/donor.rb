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

class Donor < ActiveRecord::Base

  has_attached_file :logo,
                    default_url: "/assets/:style/missing.png",
                    storage: Settings.donor_logo.storage,
                    fog_credentials: "#{Rails.root}/config/fog.yml",
                    fog_directory: (Settings.fog.directory rescue nil),
                    fog_host: (Settings.fog.host rescue nil),
                    path: Settings.fog.donor_logo_path
  validates :name, presence: true, uniqueness: { case_sensitive: false, message: "is already taken" }, length: {minimum: 2, maximum: 255}
  validates_attachment_content_type :logo,  :content_type => ["image/svg+xml","image/jpg", "image/jpeg", "image/png", "image/gif"]
  validates :logo , :presence => true

  has_many :stories
end
