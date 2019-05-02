class IllustrationCrop < ActiveRecord::Base
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
  default_url: "/images/:style/missing.png",
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
  # only_process: [:size7, :page_landscape, :page_portrait],
  storage: Settings.illustration.storage,
  fog_credentials: lambda { |attachment| attachment.instance.fog_credentials_path },
  fog_directory: lambda { |attachment| attachment.instance.fog_directory_name rescue nil},
  fog_host: lambda { |attachment| attachment.instance.fog_host_name rescue nil},
  path: Settings.fog.crop_path

  process_in_background :image, only_process: []
end

class Illustration < ActiveRecord::Base
  has_attached_file :image,
    styles: {
    large: ["1073", :jpg],
    search: ["260", :jpg],
    original_for_web: ["1000x700<", :jpg]
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
  # only_process: [:original_for_web, :search],
  storage: Settings.illustration.storage,
  fog_credentials: lambda { |attachment| attachment.instance.fog_credentials_path },
  fog_directory: lambda { |attachment| attachment.instance.fog_directory_name},
  fog_host: lambda { |attachment| attachment.instance.fog_host_name},
  path: Settings.fog.path

  process_in_background :image,
    queue: ILLUSTRATION_UPLOAD_QUEUE,
    processing_image_url: "/assets/uploading_illustration.png",
    only_process: []
end


