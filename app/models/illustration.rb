# == Schema Information
#
# Table name: illustrations
#
#  id                       :integer          not null, primary key
#  name                     :string(255)      not null
#  created_at               :datetime
#  updated_at               :datetime
#  image_file_name          :string(255)
#  image_content_type       :string(255)
#  image_file_size          :integer
#  image_updated_at         :datetime
#  uploader_id              :integer
#  attribution_text         :text
#  license_type             :integer
#  image_processing         :boolean
#  flaggings_count          :integer
#  copy_right_year          :integer
#  image_meta               :text
#  cached_votes_total       :integer          default(0)
#  reads                    :integer          default(0)
#  is_pulled_down           :boolean          default(FALSE)
#  publisher_id             :integer
#  copy_right_holder_id     :integer
#  image_mode               :boolean          default(FALSE)
#  storage_location         :string(255)
#  is_bulk_upload           :boolean          default(FALSE)
#  smart_crop_details       :text
#  organization_id          :integer
#  org_copy_right_holder_id :integer
#  album_id                 :integer
#  origin_url               :string(255)
#  uuid                     :string(255)
#  partner_reads            :json
#  partner_downloads        :json
#
# Indexes
#
#  index_illustrations_on_album_id            (album_id)
#  index_illustrations_on_cached_votes_total  (cached_votes_total)
#

class Illustration < ActiveRecord::Base
  acts_as_votable
  make_flaggable
  include Shared

  after_create :add_uuid_and_origin_url

  after_create :reindex_illustrations
  after_create :update_smart_crop_details
  scope :flagged, -> { where("flaggings_count >= 1 and is_pulled_down is false") }
  scope :pulled_down, -> { where("flaggings_count >= 1 and is_pulled_down is true")}

  searchkick callbacks: :async,
             searchable: [:name, :illustrators, :tags_name, :attribution_text, :categories, :styles, :dummy],
             filterable: [:styles, :illustrators, :categories, :organization, :publisher, :illustrator_slugs, :tags_name],
             mappings: {
               illustration: {
                 properties: {
                   likes: {type: "long"},
                   reads: {type: "long"},
                   is_publisher_image: {type: "boolean"},
                   is_flagged: {type: "boolean"}
                 }
               }
             },
             merge_mappings: true

  ILLUSTRATION_UPLOAD_QUEUE = 'illustration_upload'
  LICENSE_TYPES={'CC BY 0' => 0, 'CC BY 3.0' => 1, 'CC BY 4.0' => 2, 'Public Domain' => 3}
  enum license_type: LICENSE_TYPES

  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  acts_as_taggable
  after_update :reprocess_image, :if => :cropping?
  validates :name, presence: true, length: {maximum: 255}
  validate :uniqueness_of_name, on: :create
  # validates_uniqueness_of :name, conditions: -> { joins(:illustrators).where("illustrators_illustrations.person_id" => self.illustrators.map(&:id)) }
  validates :styles, presence: true
  validates :categories, presence: true

  has_and_belongs_to_many :illustrators,
    class_name: 'Person', join_table: 'illustrators_illustrations'

  has_and_belongs_to_many :photographers,
    class_name: 'User', join_table: 'illustrations_photographers'

  belongs_to :album

  accepts_nested_attributes_for :illustrators, :allow_destroy => true
  # has_many :illustrators, class_name: 'Person'
  validates :illustrators, presence: true, length: {maximum: 3}
  belongs_to :uploader, class_name: 'User'
  belongs_to :publisher
  belongs_to :organization
  validates :uploader, presence: true
  validates :license_type, presence: true
  validate :check_child_illustrators, on: :create

  has_and_belongs_to_many :categories, class_name: 'IllustrationCategory'
  has_and_belongs_to_many :styles, class_name: 'IllustrationStyle'
  has_many :illustration_crops
  has_many :illustration_downloads, dependent: :destroy
  has_many :pulled_downs, as: :pulled_down
  belongs_to :organization
  belongs_to :copy_right_holder, class_name: 'User'
  belongs_to :org_copy_right_holder, class_name: 'Organization'
  has_and_belongs_to_many :contests
  has_many :ratings, :as => :rateable
  has_many :child_illustrators, dependent: :destroy
  accepts_nested_attributes_for :child_illustrators, :allow_destroy => true
  has_and_belongs_to_many :favorites, class_name: "Story", join_table: "favorites"
  # SIZE_BREAKPOINTS = [320, 360, 480, 640, 800, 1600]
  SIZE_BREAKPOINTS = [359, 479, 490, 767, 900, 1365]

  has_attached_file :image,
    styles: {
    large: ["1073", :jpg],
    search: ["260", :jpg],
    original_for_web: ["1000x1000<", :jpg]
  },
  default_url: "/assets/:style/missing.png",
  convert_options:
  {
    # web: '-units "PixelsPerInch" -density "96" -resample "96x96"',
    large: '-quality 85',
    search: '-quality 85',
    # original_for_web: '-quality 85 -units "PixelsPerInch" -density "96" -resample "96x96"'
    original_for_web: '-quality 85'
  },
  only_process: [:original_for_web, :search],
  storage: Settings.illustration.storage,
  fog_credentials: lambda { |attachment| attachment.instance.fog_credentials_path },
  fog_directory: lambda { |attachment| attachment.instance.fog_directory_name},
  fog_host: lambda { |attachment| attachment.instance.fog_host_name},
  path: Settings.fog.path
  validate :uniqness_of_tags

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

  def uniqness_of_tags
    if self.tag_list.present?
      all_tags = self.tag_list
      temp_tags = all_tags.map{ |f| f.downcase.strip }
      all_tags.each do |tag|
        if temp_tags.count(tag.downcase.strip) > 1
          self.errors.add(:base, "Tag name should be different.")
          break
        end
      end
    end
  end

  def fog_credentials_path
    self.storage_location.nil? ? YAML.load_file("#{Rails.root}/config/local_fog.yml") : YAML.load_file("#{Rails.root}/config/fog.yml")
  end

  def fog_host_name
    self.storage_location.nil? ? (Settings.fog.local_host) : (Settings.fog.host)
  end

  def fog_directory_name
    self.storage_location.nil? ? (Settings.fog.local_directory) : (Settings.fog.directory)
  end

  process_in_background :image,
    queue: ILLUSTRATION_UPLOAD_QUEUE,
    processing_image_url: "/assets/uploading_illustration.png",
    only_process: [:large]

  validates :image, presence: true
  validates_attachment_content_type :image, :content_type => %w(image/jpeg image/jpg image/png)

  #TODO need to put in presence validation once uploader is able to recognize
  #attribution text
  validates :attribution_text, length: {maximum: 500}
  # validate :validate_ppi, on: :create
  
  def check_child_illustrators
    if self.child_illustrators.size >=1
      self.child_illustrators.each do |ci|
        if ci.name.empty? || ci.name.nil?
          self.errors.add(:base, "Child name can't be blank")
          break
        end
      end
    end
  end

  def update_smart_crop_details
    smart_crop_js = "#{Rails.root}/lib/smart_crop/crop.js"
    local_directory = Settings.fog.local_directory
    image = "#{Rails.root}/public/#{local_directory}/#{self.image.path}"
    output = `nodejs "#{smart_crop_js}" "#{image}" 320 240`
    smart_x = output.split(" ")[0].to_f/self.image_geometry.width rescue 0
    smart_y = output.split(" ")[1].to_f/self.image_geometry.height rescue 0
    self.smart_crop_details = JSON.dump({x: smart_x, y: smart_y})
    self.save!
  end

  def flag_status current_user
    flagged_by?(current_user) || (current_user.content_manager? && flagged?)
  end

  def parsed_smart_crop_details
    JSON.parse(smart_crop_details) rescue {}
  end

  def search_data()
    {
      name: name,
      tags_name: tags.map(&:name),
      illustrators: illustrators.map(&:name),
      illustrator_slugs: illustrators.map{|i| i.user ? i.user.slug : ''},
      categories: categories.map(&:name),
      styles: styles.map(&:name),
      license_type: license_type,
      image_url: image.url(:search),
      updated_at: updated_at,
      created_at: created_at,
      url_slug: to_param,
      attribution_text: attribution_text,
      likes: likes,
      liked_users: self.get_likes.map{|like| like.voter.id} || [],
      reads: reads,
      high_res_image_url: image.url(:original),
      low_res_image_url: image.url(:large),
      is_pulled_down: is_pulled_down,
      publisher_slug: (publisher.organization.slug rescue ''),
      publisher: (publisher.name rescue ''),
      organization: (organization.organization_name rescue ''),
      contest_id: contests.map{|c| c.id} || [],
      image_mode: image_mode,
      child_illustrators: child_illustrators.map(&:name),
      favorites: favorites.map(&:id) || [],
      dummy: "dummyField", # Dummy field to extract all images and sort by required query
      crop_coords: (parsed_smart_crop_details rescue {"x"=>0, "y" => 0}),
      image_sizes: get_image_sizes,
      illustrator_details: get_illustrator_details,
      is_publisher_image: (organization.present? && organization.publisher?),
      is_flagged: flagged?
    }
  end

  def get_illustrator_details
    illustrators.map{|i| i.user ? {:name => i.user.name, :slug => i.user.slug} : {}}
  end

  def get_image_sizes
    if image
      [:large, :search].map{|size|{:height => (image_geometry(size).height rescue 0), :width =>(image_geometry(size).width rescue 0), :url=>image.url(size)}}
    end
  end

  def process_crop!(page, local_image = nil, x = 0, y = 0, w = nil, h = nil)
    filename = File.join(Rails.root,'tmp',"#{SecureRandom.hex}.png")
    w ||= self.image_geometry.width
    h ||= self.image_geometry.height

    img = load_image(local_image)
    crop = img.crop(x,y,w,h)
    crop.format = 'PNG'
    #TODO refactor to deal with buffer
    crop.write(filename)
    f = File.open(filename)
    illustration_crop = illustration_crops.new
    illustration_crop.pages << page
    illustration_crop.image  = f
    illustration_crop.save
    f.close
    File.delete(filename)
    illustration_crop
  end

  def process_crop_background!(illustration_crop, page, local_image = nil, x = 0, y = 0, w = nil, h = nil)
    filename = File.join(Rails.root,'tmp',"#{SecureRandom.hex}.png")
    w ||= self.image_geometry.width
    h ||= self.image_geometry.height
    img = load_image(local_image)
    crop = img.crop(x,y,w,h)
    crop.format = 'PNG'
    #TODO refactor to deal with buffer
    crop.write(filename)
    f = File.open(filename)
    illustration_crop.pages << page
    illustration_crop.image  = f
    illustration_crop.save
    illustration_crop.update_smartcrop_details
    page.story.reindex
    f.close
    File.delete(filename)
  end

  def reindex_illustrations
    self.reindex
  end

  def self.get_style(dimension)
    dimension = dimension.to_i
    #sizes = new.image.styles.select{|k,v| !v.name.match(/size/).nil?}.map{|k,v|[k,v.geometry.to_i]}
    "size#{(SIZE_BREAKPOINTS.index(SIZE_BREAKPOINTS.find{|point|point>dimension})||6)+1}".to_sym
  end

  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end

  def image_geometry(style = :original)
    @geometry ||= {}
    if image.image_size(style) != 'x'
      @geometry[style] ||= Paperclip::Geometry.new({width: image.width(style), height: image.height(style)})
    else
      @geometry[style] ||= Paperclip::Geometry.from_file(load_image_for_geometry(style)) rescue (Paperclip::Geometry.from_file(image.url(style)) unless (Rails.env == 'development' && Rails.env == 'test'))
    end
  end

  def user_email
    illustrator_email
  end

  def illustrator_name
    illustrators.map(&:name).join(', ')
  end

  def category_names
    categories.collect(&:name).join(', ')
  end

  def style_names
    styles.collect(&:name).join(', ')
  end

  def number_of_parent_stories_used_in
    illustration_crops.map{|illustration_crop| illustration_crop.pages.map{|p| p.story if p.story.status == "published" && (p.story.present? && p.story.root?)}}.flatten.compact.uniq.count
  end

  def number_of_child_stories_used_in
    illustration_crops.map{|illustration_crop| illustration_crop.pages.map{|p| p.story if p.story.status == "published" && (p.story.present? && !p.story.root?)}}.flatten.compact.uniq.count
  end

  def parent_story_links
    illustration_crops.map{|illustration_crop| illustration_crop.pages.map{|p| p.story if p.story.status == "published" && (p.story.present? && p.story.root?)}}.flatten.compact.uniq
  end

  def all_story_links
    illustration_crops.map{|illustration_crop| illustration_crop.pages.map{|p| p.story if p.story.status == "published" && p.story.present?}}.flatten.compact.uniq
  end

  def illustrator_email
    illustrators.map(&:user).compact.map(&:email)
  end

  def illustrator_bio
    illustrators.map(&:user).compact.map(&:bio)
  end

  def set_copyright(params,current_user)
    user = ''
    if params[:copy_right_holder_id] == "Illustrator"
      user = User.find(self.illustrators.first.user_id)
      self.update_attribute(:copy_right_holder, user)
    else
      sw_organization = Organization.find_by_email("storyweaver@prathambooks.org")
      pratham_organization = Organization.find_by_email("pbsw@prathambooks.org")
      begin
        organization = current_user.content_manager? ? Organization.find(params[:organization_id]) : (current_user.organization? ?  current_user.organization : nil)
      rescue ActiveRecord::RecordNotFound => e
        organization = nil
      end
      user = sw_organization == organization ? pratham_organization : organization
      self.update_attribute(:org_copy_right_holder, user)
    end
  end

  def private_image_access(current_user)
    return (current_user.content_manager? || self.illustrators.collect(&:user_id).include?(current_user.id)) ? true : false
  end

  def set_illustrator(params,current_user)
    self.uploader = current_user
    begin
      organization = current_user.content_manager? ? Organization.find(params[:organization_id]) : (current_user.organization? ? current_user.organization : nil)
    rescue ActiveRecord::RecordNotFound => e
      organization = nil
    end
    self.organization = organization if organization

    if(current_user.organization? || current_user.has_role?(:content_manager))
      illustrators = params[:illustrators_attributes] || []
      illustrators.select{|key,value| value[:_destroy].nil? || value[:_destroy] == 'false'}
      .each do |key,value|
          illustrator_first_name = value[:first_name]
          illustrator_last_name = value[:last_name]
          
          illustrators_email = value[:email].strip
          illustrator_bio = value[:bio]

          illustrator_user = User.find_by_email(illustrators_email) ||
                    User.new(
                      first_name: illustrator_first_name,
                      last_name: illustrator_last_name,
                      email: illustrators_email,
                      password: User.generate_random_password,
                      bio: illustrator_bio
                    )

             
          unless illustrator_user.person.nil?
            self.illustrators << illustrator_user.person
          else
            illustrator_person = Person.new(
              :first_name => illustrator_first_name,
              :last_name => illustrator_last_name,
              :user => illustrator_user)
            self.illustrators << illustrator_person
          end
      end
      
      illustration_valid = self.valid?
      illustrators_valid = self.illustrators.select { |i| !i.valid? }.size == 0
      illustrator_users_valid = self.illustrators.collect(&:user).select { |u| !u.try(:valid?)}.size == 0

      if illustration_valid && illustrators_valid && illustrator_users_valid
        self.save
        self.illustrators.each {|illustrator| illustrator.save }
        self.illustrators.collect(&:user).each { |user| user.save }
      end
    else
        illustrator_user = current_user
        illustrator_first_name = current_user.first_name
        illustrator_last_name = current_user.last_name
        illustrator_person = Person.find_by(:first_name => illustrator_first_name,:last_name => illustrator_last_name) ||
               Person.new(
                  :first_name => illustrator_first_name,
                  :last_name => illustrator_last_name)

        if illustrator_user.person.nil?
          illustrator_person.user = illustrator_user
        end
        self.illustrators << illustrator_person
        self.save
        self.illustrators.each {|illustrator| illustrator.save }

    end
    !self.errors.any?
  end

 def set_contest_illustrators(current_user)
    self.uploader = current_user
    illustrator_user = current_user
    illustrator_first_name = current_user.first_name
    illustrator_last_name = current_user.last_name
    illustrator_person = Person.find_by(:first_name => illustrator_first_name,:last_name => illustrator_last_name) ||
           Person.new(
              :first_name => illustrator_first_name,
              :last_name => illustrator_last_name)

    if illustrator_user.person.nil?
      illustrator_person.user = illustrator_user
    end
    self.illustrators << illustrator_person
    self.save
    self.illustrators.each {|illustrator| illustrator.save }

    !self.errors.any?
 end


  def save_person_if_doesnot_exit(illustrator_user,illustrator_person)
    if illustrator_user.person.nil?
      illustrator_person.user = illustrator_user 
      illustrator_person.save
    end
    illustrator_person
  end
  
  def to_param
    url_slug(id, name)
  end

  def likes
    self.cached_votes_total
  end

  def self.increment!(ids, attr_name)
    Shared.increment_read!(ids, self.table_name, attr_name, self.connection)
    Illustration.where(id: ids).each{|illustration| illustration.reindex}
  end

  def used_in_published_stories
    illustration_crops.map{|illustration_crop| illustration_crop.pages.collect(&:story)}.flatten.map {|story| story if story.published? }.compact.uniq
  end

  def used_in_de_activated_stories
    Story.joins(:pages).where(pages: {illustration_crop_id: illustration_crops.map{|i| i.id}}).where(status: 5).uniq
  end

  def send_pulled_down_notification(pulled_down_stories,reason)
    flaggings = self.flaggings.where(:sent_mails => false)
    self.illustrators.each do |illustrator|
      UserMailer.delay(:queue=>"mailer").pulled_down_illustration_mail(illustrator,self,reason.split(","))
    end
    pulled_down_stories.each do |story|
      story.authors.each do |author|
        pages = story.pages.map {|page| page.position if page.illustration  == self }.compact.join(", ")
        UserMailer.delay(:queue=>"mailer").pulled_down_story_by_illustration_mail(author,self,story,pages)
      end
    end 
    flaggings.each do |flagging|
      UserMailer.delay(:queue=>"mailer").illustration_flagger_email(flagging.flagger, self)
      flagging.update_attribute(:sent_mails, true)
    end
  end

  def update_downloads(current_user, ip_address, type)
    download = IllustrationDownload.new
    download.user = current_user
    download.illustration = self
    download.download_type = type
    download.ip_address = ip_address
    download.save!
  end

  def self.upload_illustrations_to_cloud
    credentials =  YAML.load_file("#{Rails.root}/config/fog.yml")
    connection = Fog::Storage.new(credentials.values.first.symbolize_keys!)
    directory = connection.directories.get(Settings.fog.directory)
    local_directory = Settings.fog.local_directory
    illustrations = Illustration.where(:storage_location => nil)
    illustrations.each do |illustration|
      puts illustration.id
      unless illustration.image.processing?
        styles = illustration.image.styles.keys << :original
        styles.each do |style|
          puts style
          if File.exist?("#{Rails.root}/public/#{local_directory}/#{illustration.image.path(style)}")
            file = directory.files.create(
                :key    => "#{illustration.image.path(style)}",
                :body => File.open("#{Rails.root}/public/#{local_directory}/#{illustration.image.path(style)}"),
                :public => true
            )
            file.body = File.open("#{Rails.root}/public/#{local_directory}/#{illustration.image.path(style)}")
            file.save
          end
          #File.delete("#{Rails.root}/#{directory}/#{illustration.image.path(style)}") if File.exist?("#{Rails.root}/#{directory}/#{illustration.image.path(style)}")
        end
        illustration.storage_location = "google"
        illustration.save
      end
    end
  end

  def self.remove_illustrations_from_local_storage
    local_directory = Settings.fog.local_directory
    illustrations = Illustration.where(:storage_location => "google").where("created_at < ?", 1.day.ago)
    illustrations.each do |illustration|
      FileUtils.rm_rf("#{Rails.root}/public/#{local_directory}/illustrations/#{illustration.id}")
    end
  end

  private
  def reprocess_image
    image.assign(image)
    image.save
  end

  def validate_ppi
    return if image == nil || Rails.env.test?
    resolution = Paperclip::Resolution.new(image.queued_for_write[:original].path).make
    if resolution < 300
      errors.add :image, "DPI should be atleast 300x300"
    end
  end

  def load_image(local_image)
    if !local_image.nil?
      img = Magick::Image.read(local_image)[0]
    elsif Rails.env == 'production'
      if self.storage_location.nil?
        img = Magick::Image.read("public/#{Settings.fog.local_directory}/#{image.path}")[0]
      else
        img = Magick::Image.read(image.public_url)[0]
      end
    elsif Rails.env == 'development'
      img = Magick::Image.read("public/system/story-weaver/#{image.path}")[0]
    else
      img = Magick::Image.read(image.path)[0]
    end
  end

  def load_image_for_geometry(style)
    if Rails.env == 'test'
      img = image.try(Settings.illustration.path, style)
    elsif Rails.env == 'development'
      img = open("public/#{Settings.fog.directory}/#{image.try(Settings.illustration.path, style)}")
    else
      img = open(image.try(Settings.illustration.path, style))
    end
  end

  def uniqueness_of_name
    present = Illustration.joins(:illustrators).where("illustrators_illustrations.person_id" => self.illustrators.map(&:id)).where(name: self.name).count
    if present>0
      errors.add(:name,"is not unique for given illustrators #{self.illustrator_name}")
      false
    end
    true
  end

  def is_publisher?
    uploader.try(:role) == "publisher"
  end


end

