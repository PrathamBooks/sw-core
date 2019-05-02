# == Schema Informatio
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

  DEFAULT_GEOMETRY = "100%"
  DEFAULT_PAPERCLIP_OPTIONS = {geometry: DEFAULT_GEOMETRY,animated: :true}

  has_attached_file :image,
    styles: lambda { |attachment|
    paperclip_options = DEFAULT_PAPERCLIP_OPTIONS.merge(format: attachment.instance.image_format)
    {
      page_landscape: paperclip_options.merge(geometry: (attachment.instance.pages[0].page_template.scaled_dimension_for_size(98) rescue DEFAULT_GEOMETRY) , format: 'png'),
      page_portrait:  paperclip_options.merge(geometry: (attachment.instance.pages[0].page_template.scaled_dimension_for_size(50) rescue DEFAULT_GEOMETRY) , format: 'png'),
      size1: paperclip_options.merge(geometry: (attachment.instance.pages[0].page_template.scaled_dimension_for_size(268) rescue DEFAULT_GEOMETRY )),
      size2: paperclip_options.merge(geometry: (attachment.instance.pages[0].page_template.scaled_dimension_for_size(308) rescue DEFAULT_GEOMETRY )),
      size3: paperclip_options.merge(geometry: (attachment.instance.pages[0].page_template.scaled_dimension_for_size(428) rescue DEFAULT_GEOMETRY )),
      size4: paperclip_options.merge(geometry: (attachment.instance.pages[0].page_template.scaled_dimension_for_size(548) rescue DEFAULT_GEOMETRY )),
      size5: paperclip_options.merge(geometry: (attachment.instance.pages[0].page_template.scaled_dimension_for_size(708) rescue DEFAULT_GEOMETRY )),
      size6: paperclip_options.merge(geometry: (attachment.instance.pages[0].page_template.scaled_dimension_for_size(803) rescue DEFAULT_GEOMETRY )),
      size7: paperclip_options.merge(geometry: (attachment.instance.pages[0].page_template.scaled_dimension_for_size(959) rescue DEFAULT_GEOMETRY )),
      large: paperclip_options.merge(geometry: (attachment.instance.pages[0].page_template.scaled_dimension_for_size(1073) rescue DEFAULT_GEOMETRY )),
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
  only_process: [:size7, :size1, :page_landscape, :page_portrait],
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

  def image_format
    if image_content_type && image_content_type.split('/')[1]  == 'gif'
      :gif
    else
      :jpg
    end
  end

  def url_path(style, file_name, content_type)
    if file_name.nil?
      return
    end
    if Rails.env == 'test'
      '/' + Settings.fog.crop_url_path + '/' + self.id.to_s + '/' + style.to_s + '/' + file_name.gsub(/#{Regexp.escape(File.extname(file_name))}\Z/, "") + ".#{content_type}"
    elsif file_name
      fog_host_name + '/' + 'illustration_crops' + '/' + self.id.to_s + '/' + style.to_s + '/' + file_name.gsub(/#{Regexp.escape(File.extname(file_name))}\Z/, "") + ".#{content_type}"
    else
      Settings.fog.local_host + '/' + 'images' + '/' + 'uploading_illustration.png'
    end
  end

  def url(style=:original)
    url_path(style, image_file_name, image_format.to_s)
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
        illustration_crop.pages.map{|p| p.story.reindex if p.story}
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

  def generate_smart_crop_details
    smart_crop_js = "#{Rails.root}/lib/smart_crop/crop.js"
    local_directory = Settings.fog.local_directory
    image = "#{Rails.root}/public/#{local_directory}/#{self.image.path}"
    output = `nodejs "#{smart_crop_js}" "#{image}" 224 224`
    smart_x = (output.split(" ")[0].to_f/image_geometry.width) rescue 0
    smart_y = (output.split(" ")[1].to_f/image_geometry.height) rescue 0
    { 'x' => smart_x, 'y' => smart_y}
  end

  def update_smartcrop_details
    self.update( :smart_crop_details => JSON.dump(generate_smart_crop_details))
  end

  private
  def reprocess_image
    image.assign(image)
    image.save
  end

end
