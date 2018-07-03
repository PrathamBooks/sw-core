# == Schema Information
#
# Table name: illustration_crops
#
#  id                 :integer          not null, primary key
#  illustration_id    :integer
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  created_at         :datetime
#  updated_at         :datetime
#  image_processing   :boolean
#  crop_details       :text
#  image_meta         :text
#  storage_location   :string(255)
#  smart_crop_details :text
#  origin_url         :string(255)
#  uuid               :string(255)
#
# Indexes
#
#  index_illustration_crops_on_illustration_id  (illustration_id)
#

require 'utils/utils'
class IllustrationCrop < ActiveRecord::Base

  after_create :add_uuid_and_origin_url

  belongs_to :illustration
  has_many :pages
  delegate :story, to: :pages, allow_nil: true

  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  # after_update :reprocess_image, :if => :cropping?

  DEFAULT_PAPERCLIP_OPTIONS = {geometry: "100%",format: :jpg}

  has_attached_file :image,
    styles: lambda { |attachment|
    {
      page_landscape: DEFAULT_PAPERCLIP_OPTIONS.merge(geometry: attachment.instance.pages[0].page_template.scaled_dimension_for_size(98),format: :png),
      page_portrait:  DEFAULT_PAPERCLIP_OPTIONS.merge(geometry: attachment.instance.pages[0].page_template.scaled_dimension_for_size(50),format: :png),
      size1: DEFAULT_PAPERCLIP_OPTIONS.merge(geometry: attachment.instance.pages[0].page_template.scaled_dimension_for_size(268)),
      size2: DEFAULT_PAPERCLIP_OPTIONS.merge(geometry: attachment.instance.pages[0].page_template.scaled_dimension_for_size(308)),
      size3: DEFAULT_PAPERCLIP_OPTIONS.merge(geometry: attachment.instance.pages[0].page_template.scaled_dimension_for_size(428)),
      size4: DEFAULT_PAPERCLIP_OPTIONS.merge(geometry: attachment.instance.pages[0].page_template.scaled_dimension_for_size(548)),
      size5: DEFAULT_PAPERCLIP_OPTIONS.merge(geometry: attachment.instance.pages[0].page_template.scaled_dimension_for_size(708)),
      size6: DEFAULT_PAPERCLIP_OPTIONS.merge(geometry: attachment.instance.pages[0].page_template.scaled_dimension_for_size(803)),
      size7: DEFAULT_PAPERCLIP_OPTIONS.merge(geometry: attachment.instance.pages[0].page_template.scaled_dimension_for_size(959)),
      large: DEFAULT_PAPERCLIP_OPTIONS.merge(geometry:attachment.instance.pages[0].page_template.scaled_dimension_for_size(1073))
    }
  },
  default_url: "/assets/:style/missing.png",
  convert_options:
  {
    # TODO Found a crazy bug which causes canvas to be bigger than crop when using -flatten
    # size1: '-quality 85 -background "white" -flatten',
    # size2: '-quality 85 -background "white" -flatten',
    # size3: '-quality 85 -background "white" -flatten',
    # size4: '-quality 85 -background "white" -flatten',
    # size5: '-quality 85 -background "white" -flatten',
    # size6: '-quality 85 -background "white" -flatten',
    # large: '-quality 85 -background "white" -flatten',
    size1: '-quality 85 -background "white"',
    size2: '-quality 85 -background "white"',
    size3: '-quality 85 -background "white"',
    size4: '-quality 85 -background "white"',
    size5: '-quality 85 -background "white"',
    size6: '-quality 85 -background "white"',
    size7: '-quality 85 -background "white"',
    large: '-quality 85 -background "white"'
  },
  only_process: [:size7, :page_landscape, :page_portrait],
  storage: Settings.illustration.storage,
  fog_credentials: lambda { |attachment| attachment.instance.fog_credentials_path },
  fog_directory: lambda { |attachment| attachment.instance.fog_directory_name rescue nil},
  fog_host: lambda { |attachment| attachment.instance.fog_host_name rescue nil},
  path: Settings.fog.crop_path

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

  def fog_credentials_path
    self.storage_location.nil? ? YAML.load_file("#{Rails.root}/config/local_fog.yml") : YAML.load_file("#{Rails.root}/config/fog.yml")
  end

  def fog_host_name
    self.storage_location.nil? ? (Settings.fog.local_host) : (Settings.fog.host)
  end

  def fog_directory_name
    self.storage_location.nil? ? (Settings.fog.local_directory) : (Settings.fog.directory)
  end

  def url(style=:original)
    if Rails.env == 'test'
      '/' + Settings.fog.crop_url_path + '/' + self.id.to_s + '/' + style.to_s + '/' + self.image_file_name.gsub(/#{Regexp.escape(File.extname(self.image_file_name))}\Z/, "") + '.jpg' 
    elsif self.image_file_name
      fog_host_name + '/' + 'illustration_crops' + '/' + self.id.to_s + '/' + style.to_s + '/' + self.image_file_name.gsub(/#{Regexp.escape(File.extname(self.image_file_name))}\Z/, "") + '.jpg'
    else
      Settings.fog.local_host + '/' + 'images' + '/' + 'uploading_illustration.png'
    end
  end

  process_in_background :image,
                        url_with_processing: false,
                        queue: Illustration::ILLUSTRATION_UPLOAD_QUEUE,
                        #processing_image_url: "/assets/uploading_illustration.png",
                        only_process: [:size1, :size2, :size3, :size4, :size5, :size6, :large]

  #validates :image, presence: true
  #validates_attachment_content_type :image, :content_type => %w(image/jpeg image/jpg image/png)
  do_not_validate_attachment_file_type :image
  # def cropping?
  #   !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  # end

  def image_geometry(style = :original)
    @geometry ||= {}
    if image.image_size(style) != 'x'
      @geometry[style] ||= Paperclip::Geometry.new({width: image.width(style), height: image.height(style)})
    else
      @geometry[style] ||= Paperclip::Geometry.from_file(load_image(style))
    end  
  end

  def parsed_crop_details
    JSON.parse(crop_details) rescue {}
  end

  def parsed_smart_crop_details
    JSON.parse(smart_crop_details) rescue {}
  end

  def save_crop_data!(data)
    self.crop_details = JSON.dump(data)
    save!
  end

  def load_image(style = :original)
    if Rails.env == 'test'
      img = image.try(Settings.illustration.path, style)
    elsif Rails.env == 'development'
      img = open("public/#{Settings.fog.directory}/#{image.try(Settings.illustration.path, style)}")
    else
      img = Utils.download_to_file(image.try(Settings.illustration.path, style))
    end
  end

  def crop_size(size)
    {:page_landscape => 9.786, :page_portrait => 19.18, :size1 => 3.578, :size2 => 3.114, :size3 => 2.241, :size4 => 1.75, :size5 => 1.35, :size6 => 1.19}
  end

  def self.upload_illustration_crops_to_cloud
    credentials =  YAML.load_file("#{Rails.root}/config/fog.yml")
    connection = Fog::Storage.new(credentials.values.first.symbolize_keys!)
    directory = connection.directories.get(Settings.fog.directory)
    local_directory = Settings.fog.local_directory
    illustration_crops = IllustrationCrop.where(:storage_location => nil)
    illustration_crops.each do |illustration_crop|
      puts illustration_crop.id
      if illustration_crop.pages.any? && illustration_crop.image.present? && !illustration_crop.image.processing?
        styles = illustration_crop.image.styles.keys << :original
        styles.each do |style|
          puts style
          if File.exist?("#{Rails.root}/public/#{local_directory}/#{illustration_crop.image.path(style)}")
            file = directory.files.create(
                :key    => "#{illustration_crop.image.path(style)}",
                :body => File.open("#{Rails.root}/public/#{local_directory}/#{illustration_crop.image.path(style)}"),
                :public => true
            )
            file.body = File.open("#{Rails.root}/public/#{local_directory}/#{illustration_crop.image.path(style)}")
            file.save
          end
          #File.delete("#{Rails.root}/#{directory}/#{illustration_crop.image.path(style)}") if File.exist?("#{Rails.root}/#{directory}/#{illustration_crop.image.path(style)}")
        end
        illustration_crop.storage_location = "google"
        illustration_crop.save
      end
    end
  end

  def self.remove_illustration_crops_from_local_storage
    local_directory = Settings.fog.local_directory
    illustration_crops = IllustrationCrop.where(:storage_location => "google").where("created_at < ?", 1.day.ago)
    illustration_crops.each do |illustration_crop|
      FileUtils.rm_rf("#{Rails.root}/public/#{local_directory}/illustration_crops/#{illustration_crop.id}")
    end
  end

  def update_smartcrop_details
    smart_crop_js = "#{Rails.root}/lib/smart_crop/crop.js"
    local_directory = Settings.fog.local_directory
    image = "#{Rails.root}/public/#{local_directory}/#{self.image.path}"
    output = `nodejs "#{smart_crop_js}" "#{image}" 224 224`
    smart_x = (output.split(" ")[0].to_f/self.image_geometry.width) rescue 0
    smart_y = (output.split(" ")[1].to_f/self.image_geometry.height) rescue 0
    self.smart_crop_details = JSON.dump({x: smart_x, y: smart_y})
    self.save!
  end

  private
  def reprocess_image
    image.assign(image)
    image.save
  end

end
