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
#  origin_url                 :string(255)
#  uuid                       :string(255)
#
# Indexes
#
#  index_users_on_auth_token            (auth_token)
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

class User < ActiveRecord::Base
  searchkick match: :word_start,
             searchable: [:name, :first_name, :last_name],
             merge_mappings: true
  make_flagger :flag_once => true
  after_create :add_uuid_and_origin_url
  acts_as_voter
  has_attached_file :logo,
  default_url: "/assets/:style/missing.png",
  storage: Settings.logo.storage,
  fog_credentials: "#{Rails.root}/config/fog.yml",
  fog_directory: (Settings.fog.directory rescue nil),
  fog_host: (Settings.fog.host rescue nil),
  path: Settings.fog.logo_path

  has_attached_file :profile_image,
  default_url: ->(attachment) { ActionController::Base.helpers.asset_path('profile_image.svg') },
  storage: Settings.profile_image.storage,
  fog_credentials: "#{Rails.root}/config/fog.yml",
  fog_directory: (Settings.fog.directory rescue nil),
  fog_host: (Settings.fog.host rescue nil),
  path: Settings.fog.profile_image_path
  validates :first_name, presence: true, length: {minimum: 2, maximum: 255}
  validates :email, length: {maximum: 255} 
  validates :role, presence: true
  validates :bio, length: {maximum: 512}

  validates_attachment_content_type :profile_image,  :content_type => ["image/svg+xml","image/jpg", "image/jpeg", "image/png", "image/gif"]
  #validates :profile_image , :presence => true

  validates_attachment_content_type :logo,  :content_type => ["image/svg+xml","image/jpg", "image/jpeg", "image/png", "image/gif"]
  validates :logo , :presence => true , :if => :is_publisher? || :is_translator

  enum role: {user: 0, reviewer: 1, content_manager: 2, publisher: 3, admin: 4, recommender: 5, promotion_manager: 6, translator: 7, outreach_manager: 8}
  after_initialize :set_default_role, :if => :new_record?

  has_and_belongs_to_many :stories, -> { order('updated_at DESC') },
    class_name: 'Story', join_table: 'authors_stories'
  has_many :story_downloads, dependent: :destroy
  has_many :illustration_downloads, dependent: :destroy
  has_many :list_downloads, dependent: :destroy
  has_many :story_reads
  has_many :re_published_stories
  has_many :ratings
  has_one :story
  belongs_to :organization
  accepts_nested_attributes_for :organization
  has_many :reviewers_languages
  has_and_belongs_to_many :tlanguages, class_name: 'Language', join_table: 'translators_languages'
  has_many :languages, through: :reviewers_languages, source: :language

  has_many :reviewer_comments
  has_many :reviewer_stories, through: :reviewer_comments, source: :story
  has_one :institutional_user
  accepts_nested_attributes_for :institutional_user
  has_many :lists
  has_many :list_likes
  has_many :likes, through: :list_likes, source: :list
  has_many :list_views
  has_many :media_mentions
  has_and_belongs_to_many :albums, class_name: 'Album', join_table: 'albums_users'
  has_one :phonestories_popup
  has_many :user_popups
  

  def set_default_role
    self.role ||= :user
  end

  devise :database_authenticatable, :registerable, :validatable,
         :recoverable, :rememberable, :trackable,
         :async, :confirmable

  devise :omniauthable, :omniauth_providers => [:facebook,:google_oauth2]

  # default_scope {order("created_at DESC") }
  scope :normal_users, -> {where("site_roles NOT LIKE ?", "%admin%")}

  scope :content_manager, -> { where("site_roles LIKE ?", "%content_manager%") }
  scope :promotion_manager, -> { where("site_roles LIKE ?", "%promotion_manager%") }
  scope :translator, -> { where("site_roles LIKE ?", "%translator%") }
  scope :reviewer, -> { where("site_roles LIKE ?", "%content_manager%") }
  scope :outreach_manager, -> { where("site_roles LIKE ?", "%outreach_manager%") }

  has_one :person
  
  after_create :create_personal_list
  after_update :unsubscribe_user_from_mailing_list
  after_update :subscribe_user_to_mailing_list
  before_destroy :unsubscribe_user_from_mailing_list

  def search_data()
    {
        id: id,
        first_name: first_name,
        last_name: last_name,
        name: name,
        email: email,
        slug: slug,
        type: "user",
        profile_image: profile_image.url,
        created_at: created_at,
        stories_count: stories_count(),
        illustrations_count: illustrations_count()
    }
  end

  def add_uuid_and_origin_url
    if self.uuid == nil && self.origin_url == nil
      self.uuid = "#{Settings.org_info.prefix}-#{self.id}"
      self.origin_url = Settings.org_info.url
      self.save!
    elsif self.uuid == nil
      self.uuid = "#{Settings.org_info.prefix}-#{self.id}"
      self.save!
    elsif self.origin_url == nil
      self.origin_url = Settings.org_info.url
      self.save!
    end
  end
  
  def stories_count()
    stories.where(status: Story.statuses[:published]).count
  end

  def illustrations_count()
    person.nil?  ? 0 : person.illustrations.where(image_mode: false, is_pulled_down: false).count
  end

  def self.from_omniauth(auth,signed_in_resource=nil)
    create_user(parse_oauth auth)
  end

  def self.create_user auth
    user = User.where(:provider => auth[:provider], :uid => auth[:uid]).first
    if user
      return user
    else
      registered_user = User.where(:email => auth[:email]).first
      if registered_user
        return registered_user
      else
        user = User.create(
          auth.merge({
              :password => Devise.friendly_token[0,20],
              :confirmed_at => Time.now
            })
        )
      end
    end
  end

  def self.parse_oauth auth
    {
      :name     => auth.info.name,
      :provider => auth.provider,
      :uid      => auth.uid,
      :email    => auth.info.email
    }
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end

  def name
    if last_name.nil? || last_name.strip.empty?
      first_name
    else
      first_name + " " + last_name
    end
  end

  def update_tour_status
    self.update_attributes(:tour_status => true)
    self.save!
  end

  def name=(fullname)
    if fullname.include? ' '
      first,last = fullname.split(' ')
      self.first_name = first
      self.last_name = last
    else
      self.first_name=fullname
    end
  end

  def user_details
    return self.email, self.first_name, self.last_name, self.role
  end

  def role_name
    role.split("_").join(" ").capitalize
  end

  def self.generate_random_password
    SecureRandom.base64
  end

  def has_role?(user_role)
    "#{role}"=="#{user_role}"
  end

  def is_language_reviewer(language_name)
    language = self.languages.present? ? (self.languages.collect(&:name).include?(language_name) ? true : false) : false
  end

  def update_role(org_rol)
    self.organization_roles = self.organization_roles.nil? ? org_rol : self.organization_roles+","+org_rol
    self.save!
  end

  def update_site_role(site_role)
    site_roles = self.site_roles.nil? ? site_role : self.site_roles+","+site_role
    #self.save!
  end

  def is_admin(org)
    if (self && self.organization == org) && (self.organization_roles != nil && self.organization_roles.include?("admin"))
      return true
    else
      return false
    end
  end

  def is_reviewer?
    self.languages.present?
  end

  def is_editor?
    Story.where(:editor=>self).any?
  end

  def is_publisher?
    role == "publisher"
  end

  def is_translator?
    self.tlanguages.present?
  end

  def username
    "user_#{self.id}"
  end

  def profile
    {
      :id => self.id,
      :email => self.email,
      :first_name => self.first_name,
      :name => self.name,
      :last_name => self.last_name,
      :role => self.role,
      :roles => self.roles,
      :isOrganisationMember => !self.organization_id.nil?,
      :organizationRoles => self.organization_roles || ""
    }
  end

  def roles
    rs = []
    rs << "translator" if self.is_translator?
    rs << "content_manager" if self.content_manager?
    rs << "reviewer" if self.is_reviewer?
    rs << "promotion_manager" if self.promotion_manager?
    rs << "outreach_manager" if self.outreach_manager?
    rs
  end

  def organization?
    if self.organization.present? && (self.organization_roles != nil && self.organization_roles.include?("publisher"))
      return true
    else
      return false
    end
  end
  
  def content_manager?
    if self.site_roles != nil && self.site_roles.include?("content_manager")
      return true
    else
      return false
    end
  end

  def promotion_manager?
    if self.site_roles != nil && self.site_roles.include?("promotion_manager")
      return true
    else
      return false
    end
  end

  def outreach_manager?
    if self.site_roles != nil && self.site_roles.include?("outreach_manager")
      return true
    else
      return false
    end
  end

  def translator?
    if self.site_roles != nil && self.site_roles.include?("translator")
      return true
    else
      return false
    end
  end

  def reviewer?
    if self.site_roles != nil && self.site_roles.include?("reviewer")
      return true
    else
      return false
    end
  end

  def get_pulled_down_access(illustration)
     return (self.content_manager? || illustration.illustrators.collect(&:user_id).include?(self.id)) ? false : true
  end

  def blog_username
    if self.last_name.nil? || self.last_name.strip.empty?
      self.first_name
    else
      self.first_name + " " + self.last_name
    end
  end

  def admin_username
    "Admin"
  end

  def self.to_csv(options = {})
    attributes = %w{Email First_Name Last_Name}
    CSV.generate(headers: true) do |csv|
      csv << attributes
      all.each do |user|
        csv << attributes.map{ |attr| user.send(attr.downcase) }
      end
    end
  end

  def generate_auth_token
    token = SecureRandom.hex
    self.update_columns(auth_token: token)
    token
  end

  def invalidate_auth_token
    self.update_columns(auth_token: nil)
  end

  def slug
    "#{self.id}-#{self.name.parameterize}"
  end

  def language_preferences_list
    language_preferences.present? ? Language.where(:id => language_preferences.split(",")).pluck(:name) : []
  end

  def reading_levels_list
    reading_levels.present? ? reading_levels.split(",") : []
  end

  private

  def subscribe_user_to_mailing_list
    if Rails.env == 'production'
      SubscribeUserToMailingListJob.perform_later(self) if self.confirmed_at && self.email_preference
    end
  end

  def unsubscribe_user_from_mailing_list
    if Rails.env == 'production'
      UnsubscribeUserFromMailingListJobJob.perform_later(self) unless self.email_preference
    end
  end

  def create_personal_list
    list = List.new
    list.title = "My Bookshelf"
    list.user_id = self.id
    list.can_delete = false
    list.is_default_list = true
    list.save!
  end
end
