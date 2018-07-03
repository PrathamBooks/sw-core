module ApplicationHelper

  def who_label(story)
    if(story.original_authors.length>1)
      'Authors:'
    else
      'Author:'
    end
  end

  def illustrators_label(story)
    if(story.illustrators.length>1)
      'Illustrators:'
    else
      'Illustrator:'
    end
  end

  def photographers_label(story)
    if (story.photographers.length > 1)
      "Photographers:"
    else
      "Photographer:"
    end
  end

  def who_did_it(story)
    original_author_names(story)
  end

  def derivator_label(story)
    if(story.is_translation?)
      if(story.translators.length>1)
        'Translators:'
      else
        'Translator:'
      end
    elsif(story.is_relevelled?)
      'Re-level:'
    end
  end

  def derivator_names(story)
    story.author_names
  end

  def display_errors(obj)
    render :partial => "feeds/display_errors", :locals => {:obj => obj}
  end

  def page_partial(page, offline_processing = false)
    if (offline_processing)
  	  "pages/show_#{page.type.try(:underscore)||'story_page'}.html.erb"
    else
  	  "pages/show_#{page.type.try(:underscore)||'story_page'}.html.erb"
    end
  end

  def original_author_names(story)
  	story.original_authors.map(&:name).join(', ')
  end

  def illustrator_names(story)
  	story.illustrators.map(&:name).join(', ')
  end

  def display_illustrators(story,max_size)
    name = ""
    story.illustrators.each do |illustrator|
      if (name + illustrator.name).size < max_size
        name << ", " unless name.blank?
        name << illustrator.name
      else
        name << ".."
        break
      end
    end
    name
  end

  def display_photographers(story,max_size)
    name = ""
    story.photographers.each do |photographer|
      if (name + photographer.name).size < max_size
        name << ", " unless name.blank?
        name << photographer.name
      else
        name << ".."
        break
      end
    end
    name
  end

  def translator_names(story)
  	story.translators.map(&:name).join(', ')
  end

  def reading_level_help(locale,level)
    I18n.locale = locale
    text = t "story.cover_text.reading_levels.level_#{level}"
    I18n.locale = :en
    text
  end

  def reading_level_tooltip(level)
    t "story.search.reading_level_tool_tips.level_#{level}"
  end

  def reading_level_story_details(level)
    t "story.details.reading_levels.level_#{level}"
  end

  def spp_text
    t "spp.about_us"
  end

  def reading_level_logo(story)
    asset_path_as_per_request_format("#{story.reading_level}.png")
  end

  def absolute_path(path)
    _p = "#{Rails.root}/public#{path}".gsub(/\?.*/,"")
    _m = _p.match(/(.*)\/(.*)\.(.*)$/)
    search = Dir.glob(File.join(_m[1],_m[2]+"*"))
    if(!search.empty?)
      "#{search.first}"
    else
      File.join(Rails.root,"app","assets","images",_m[2],_m[3])
    end
  end

  def generating_cover?
    @generating_cover == true
  end

  def illustration_crop_image_url(page)
    page && page.illustration_crop ? page.illustration_crop.image.url(:size7) : ''
  end

  def illustration_crop_thumbnail_url(page,orientation)
    page && page.illustration_crop ? page.illustration_crop.image.url(orientation) : ''
  end

  def illustration_image_url(page)
    page && page.illustration_crop ? page.illustration_crop.illustration.image.url(:original_for_web) : ''
  end

  def illustration_crop_missing(page)
    if page.illustration_crop
      ill_crop = page.illustration_crop
      return false unless ill_crop.storage_location.nil?
      if ill_crop.image != nil && ill_crop.image.exists?
        return ill_crop.image.try(:url) == "/assets/original/missing.png" || ill_crop.image.processing?
      else
        return true
      end
    else
      return false
    end
  end

  def illustration_crop_style(page)
    illustration_dimension = page.illustration_crop.illustration.image_geometry(:original_for_web)
    illustration_width = illustration_dimension.width
    illustration_height = illustration_dimension.height
    crop_details = page.illustration_crop.parsed_crop_details
    left =  (crop_details["x"]/crop_details["ratio_x"] rescue 0)
    top  =  (crop_details["y"]/crop_details["ratio_y"] rescue 0)
    height = (illustration_height/crop_details["ratio_y"] rescue 0)
    height = default_height(page, illustration_height) if height == 0
    width = (illustration_width/crop_details["ratio_x"] rescue 0)
    width = default_width(page, illustration_width) if width == 0
    "position: relative; top: #{-top}px; left:#{-left}px; height: #{height}px; width: #{width}px;"
  end

  def preview_illustration_crop_style(page)
    illustration_dimension = page.illustration_crop.illustration.image_geometry(:original_for_web)
    illustration_width = illustration_dimension.width
    illustration_height = illustration_dimension.height
    crop_details = page.illustration_crop.parsed_crop_details
    crop_ratio = 1.137
    left =  (crop_details["x"]/crop_details["ratio_x"] rescue 0)*crop_ratio
    top  =  (crop_details["y"]/crop_details["ratio_y"] rescue 0)*crop_ratio
    height = (illustration_height/crop_details["ratio_y"] rescue 0)*crop_ratio
    height = default_height(page, illustration_height) if height == 0
    width = (illustration_width/crop_details["ratio_x"] rescue 0)*crop_ratio
    width = default_width(page, illustration_width) if width == 0
    "position: relative; top: #{-top}px; left:#{-left}px; height: #{height}px; width: #{width}px;"
  end

  def illustration_thumb_style(page)
    illustration_dimension = page.illustration_crop.illustration.image_geometry(:original_for_web)
    illustration_width = illustration_dimension.width
    illustration_height = illustration_dimension.height
    crop_details = page.illustration_crop.parsed_crop_details
    crop_ratio = 8.23
    left =  (crop_details["x"]/crop_details["ratio_x"] rescue 0)/crop_ratio
    top  =  (crop_details["y"]/crop_details["ratio_y"] rescue 0)/crop_ratio
    height = (illustration_height/crop_details["ratio_y"] rescue 0)/crop_ratio
    height = default_height(page, illustration_height)/crop_ratio if height == 0
    width = (illustration_width/crop_details["ratio_x"] rescue 0)/crop_ratio
    width = default_width(page, illustration_width)/crop_ratio if width == 0
    "position: relative; top: #{-top}px; left:#{-left}px; height: #{height}px; width: #{width}px;"
  end

  def default_height(page, illu_height)
    pg_tmp = page.page_template
    template_height = pg_tmp.orientation.to_s == 'landscape' ?
                        (pg_tmp.image_position == 'left' ? (690*pg_tmp.image_dimension)/100 : 690)
                      : (700*pg_tmp.image_dimension)/100
    illu_height/(illu_height/template_height)
  end

  def default_width(page, illu_width)
    pg_tmp = page.page_template
    template_width = pg_tmp.orientation.to_s == 'landscape' ?
      (pg_tmp.image_position == 'left' ?
        (959*pg_tmp.image_dimension)/100 : 959) : 475
    illu_width/(illu_width/template_width)
  end

  def illustration_thumbnail_url(page)
    page && page.illustration_crop ? page.illustration_crop.illustration.image.url(:original_for_web) : ''
  end

  def sorted_story_categories
    StoryCategory.order(name: :desc)
  end

  def sorted_illustrations_organizations
    organization_id = Illustration.all.collect(&:organization_id).uniq
    Organization.where(:id => organization_id)
  end

  def checked(arr,el)
    'checked=true' if arr.include?el rescue nil
  end
  
  def level_band_image(story)
    # Default level band is in English
    lb_name = "English"
    #If a language has its own level band use it.
    if(story.language.level_band)
      lb_name = story.language.level_band
    end
    if(@offline_processing)
      asset_url("Level_#{story.reading_level}_#{lb_name}.png")
    else
      asset_url("level_bands/Level_#{story.reading_level}_#{lb_name}.png")
    end
  end

  def organization_logo(story)
    if story.organization.present?
      story.organization.logo.present? ? story.organization.logo.url(:original) : ''
    else
      asset_url("publisher_logos/community.jpg")
    end
  end

  def image_organization_logo(image)
    if image.organization.present?
      image.organization.logo.present? ? image.organization.logo.url(:original) : ''
    else
      asset_url("publisher_logos/community.jpg")
    end
  end

  def level_band_image_pdf(story)
    # Default level band is in English
    lb_name = "English"
    #If a language has its own level band use it.
    if(story.language.level_band)
      lb_name = story.language.level_band
    end
    if(@offline_processing)
      asset_path_as_per_request_format("Level_#{story.reading_level}_#{lb_name}.png")
    else
      asset_path_as_per_request_format("level_bands/Level_#{story.reading_level}_#{lb_name}.png")
    end
  end

  def organization_logo_pdf(story)
    if story.organization.present?
      story.organization.logo.present? ? story.organization.logo.url(:original) : ''
    else
      asset_path_as_per_request_format("publisher_logos/community.jpg")
    end
  end

  def get_publisher_orgs
    return Organization.where(:organization_type => "Publisher").map{ |o| [o.organization_name,o.id]}
  end

  def get_title(language,text)
    return "<span class='#{language.script}'>#{text}</span>"
  end

  def crop_data_illustration_id(illustration,page)
    illustration.try(:id) || page.try(:illustration_crop).try(:illustration).try(:id)
  end

  def sorted_illustration_categories
    IllustrationCategory.order(name: :desc)
  end

  def sorted_illustration_styles
    IllustrationStyle.order(name: :desc)
  end

  def wicked_pdf_image_tag_for_illustration_crops(img, options={})
    if Rails.env == 'production'
      image_tag img, options
    else
      image_tag "file://#{Rails.root.join('public', 'system/story-weaver', img)}", options
    end
  end

  def asset_path_as_per_request_format(asset)
    if (request.format.symbol == :js rescue false) || (request.format.symbol == :html rescue false) || 
        (request.format.symbol == :json rescue false)
      return asset_path(asset)
    elsif @offline_processing
      return asset
    else
      return Rails.root.join('app', 'assets', 'images', asset)
    end
  end

  def host_url
    ENV['rootUrl'] ? ENV['rootUrl'] : "http://localhost:3000"
  end  

  def sortable(column, title = nil)
    title ||= column.titleize
    direction = sort_direction == "asc" ? "desc" : "asc"
    link_to title, {:sort => column, :direction => direction}, {:class => "sort-column"}
  end

  def contest_tabs(contest)
    if contest.name.downcase.match("spotathon")
      {"easy" => "Easy Level Entries", "medium" => "Medium Level Entries", "over_view" => "Contest Overview"}
    else
      {"adult" => "Adult Created Entries", "over_view" => "Contest Overview"}
    end
  end

  def contest_subtabs(contest)
    {"un-reviewed" => "My Un Reviewed Entries", "reviewed" => "My Reviewed Entries"}
  end

  def translateText(text, lang_name, try_lower_case=false)
    languagesList = {"French" => "fr", "Spanish" => "es"}
    cleanText = text
    if try_lower_case
      cleanText = text.downcase
    end
    cleanText = URI.encode(cleanText)
    cleanText = cleanText.gsub '&nbsp;', '%200xC2'
    response = RestClient.get "https://translation.googleapis.com/language/translate/v2?key=#{ENV['GOOGLE_APP_ID']}&source=en&target=#{languagesList[lang_name]}&format=html&q=#{cleanText}"
    formattedResp = JSON.parse(response)
    text = formattedResp["data"]["translations"][0]["translatedText"].gsub ' 0xC2', '&nbsp;'
    text = text.gsub '0xC2', '&nbsp;'
    text = HTMLEntities.new.decode text
    if try_lower_case
      text = text.split.map(&:capitalize).join(' ')
    end
    text
  end

  def getPubLogoFormat(story)
    logo_type = story.organization.present? ? story.organization.logo_content_type : ""
    extension = ".jpg"
    if(logo_type == "image/png")
      extension = ".png"
    elsif(logo_type == "image/gif")
      extension = ".gif"
    end
    return extension
  end
  
  def user_slug(user)
    "#{user.id}-#{user.name.parameterize}"
  end  
  
  def org_slug(org)
    "#{org.id}-#{org.organization_name.parameterize}"
  end

  def story_slug(story)
    if(story.language.id == 14)
      "#{story.id}-#{story.title.parameterize}"
    else
      "#{story.id}-#{story.english_title.nil? ? "untitled" : story.english_title.parameterize}"
    end
  end

  def list_slug(list)
    "#{list.id}-#{list.title.parameterize}"
  end
  
  def illustration_slug(illustration)
    "#{illustration.id}-#{illustration.name.parameterize}"
  end

  def get_image_crop_coords(illustration)
    if(illustration.smart_crop_details)
      illustration.parsed_smart_crop_details
    else
      {"x"=>0, "y" => 0}
    end
  end

  def get_image_height(illustration, size=:original)
    illustration.image_geometry(size).height
  end

  def get_image_width(illustration, size=:original)
    illustration.image_geometry(size).width
  end

  def get_image_url(illustration, size=:original)
    illustration.image.url(size)
  end

  def get_list(illustration)
    Array.new([illustration])
  end

  def get_description(blog_post)
    # Strip all the html tags from the body of the blog post
    content = strip_tags(blog_post.body)
    # unscaping the escape characters.
    content = CGI.unescapeHTML(content)
    # Replacing special characters;
    decoder = HTMLEntities.new
    content = decoder.decode(content)
    content.split('.')[0..2].join('.') if (content && content.split('.').count >= 2)
  end

  def print_date_all_stories(date)
    date.strftime("%Y-%m-%d")
  end

  def get_cover_image_url(story, size=:original)
    if(story.pages[0])
      story.pages[0].illustration_crop.url(size) if story.pages[0].illustration_crop
    end
  end

  def get_cover_image_height(story, size=:original)
    if(story.pages[0])
      story.pages[0].illustration_crop.image_geometry(size).height if story.pages[0].illustration_crop
    end
  end

  def get_cover_image_width(story, size=:original)
    if(story.pages[0])
      story.pages[0].illustration_crop.image_geometry(size).width if story.pages[0].illustration_crop
    end
  end
  
  def get_cover_image_crop_coords(story)
    if(story.pages[0])
      if(story.pages[0].illustration_crop && story.pages[0].illustration_crop.smart_crop_details)
        story.pages[0].illustration_crop.parsed_smart_crop_details
      else
        {"x"=>0, "y" => 0}
      end
    end
  end

  def get_publisher_slug(story)
    if(story.nil? || story.organization.nil? ||story.organization.organization_type != "Publisher")
      return nil
    else
      org_slug(story.organization)
    end
  end

  def get_image_publisher_slug(image)
    if(image.nil? || image.organization.nil? ||image.organization.organization_type != "Publisher")
      return nil
    else
      org_slug(image.organization)
    end
  end

  def get_banner_width(size)
    styles = {
    size_1: "692",
    size_2: "1064",
    size_3: "1436",
    size_4: "1808",
    size_5: "2180",
    size_6: "2552"
    }
    return styles[size]
  end

  def get_blog_post_image_width(size)
    blog_styles = {
    size_1: "320",
    size_2: "480",
    size_3: "640",
    size_4: "800",
    size_5: "960",
    size_6: "1120",
    size_7: "1280"
    }
    return blog_styles[size]
  end

  def get_category_home_width(size)
    cat_home_styles = {
      size_1: "240",
      size_2: "320",
      size_3: "480",
      size_4: "640"
    }
    return cat_home_styles[size]
  end

  def get_download_link(story, type)
    if(type=="epub")
      story.published? ? download_story_url(story, format: :epub) : story_page_url(story, story.pages.first, format: :epub) 
    else
      is_high_resolution = type == "A4 size (Print ready pdf)" ? true : nil
      story.published? ? download_story_url(story, format: :pdf, high_resolution: is_high_resolution) : story_page_url(story, story.pages.first, format: :pdf , high_resolution: is_high_resolution)
    end
  end
  
  def sum_of_reads_downloads(stories, object)
    if object == "reads"
      count = stories.all.sum(:reads)
    elsif object == "downloads"
      count = stories.all.sum(:downloads) + stories.all.sum(:high_resolution_downloads) + stories.all.sum(:epub_downloads)
    elsif object == "language"
      count = stories.map{|s| s.language_id}.uniq.count
    end
  end

  def illustrations_available_for_offline(story)
    story.illustrations.each do |il|
      return false if il.storage_location.nil?
    end
    return true
  end

end
