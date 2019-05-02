class ImagePage < BasePage

  FILTERS = '.pb-filters-bar__action-wrapper'.freeze
  FILTERBARSTATUS = '.pb-filters-bar__status'.freeze
  SELECTEDFILTERS = '.pb-filters-bar__pill'.freeze
  CHECKBOX = '.pb-checkbox__label'.freeze
  SEARCHFILED = 'input.pb-text-field__input'.freeze
  PBCARDTITLE = '.pb-image-card__title'.freeze
  PBCARDARTIST = '.pb-image-card__artist'.freeze
  IMAGECARDTITLE = 'h3.pb-image-card__title'.freeze
  ACCEPTTERMSANDUSE = '.pb-illustration-upload-modal__accept-clause'.freeze
  PRIVATEIMAGEUSE = '#pb-illustration-upload-modal__make-private'.freeze
  GRIDITEM = '.pb-grid__item'.freeze
  IMAGECONTAINER = '.pb-grid--4up .grid__container'.freeze
  BUTTONDISABLED = 'button--disabled'.freeze

  BULKDOWNLOADSELECT = '#bulk-download-select-format'.freeze
  SORTBY = '#filters-bar-sort-by'.freeze
  ILLUSMODALFILE = 'illustration-modal-file'.freeze
  ILLUSMODALIMGSTYLETXT = '#illustration-modal-img-style-txt'.freeze
  ILLUSMODALIMGCATEGORYTXT = '#illustration-modal-img-category-txt'.freeze
  ILLUSMODALSTYLESSEARCHFIELD = '#illustration-modal-img-styles-search-field'.freeze
  ILLUSMODALCATEGORYSEARCHFIELD = '#illustration-modal-img-category-search-field'.freeze
  ILLUSMODALEMAILSEARCHFIELD = '#illustration-upload-modal-email-search-field'.freeze

  IMAGETAB = '/illustrations'.freeze
  IMAGES = 'Images'.freeze
  UPLOADSTARTWEAVING = 'Upload & start weaving!'.freeze
  DOWNLOADMULIMAGES = 'Download Multiple Images'.freeze
  UPLOADIMAGE = 'Upload Image'.freeze
  DEFAULTIMAGENAME = 'SW-Automation'.freeze
  IMAGESTYLE = 'Image Style'.freeze
  IMAGECATEGORY = 'Image Category'.freeze
  DEFAULTSTYLE = 'Black and White'.freeze
  DEFAULTCATEGORY = 'Animals & Birds'.freeze
  IMAGENAME = 'Image name'.freeze
  DEFAULTFIRSTNAME ='Content Manager'.freeze
  DEFAULTLASTNAME = 'user'.freeze
  DEFAULTABOUTME = 'user bio'.freeze
  DEFAULTEMAIL = 'content_manager@sample.com'.freeze
  EMAILID = 'Email'.freeze
  FIRSTNAME = 'First Name'.freeze
  LASTNAME = 'Last Name'.freeze
  ABOUTME ='About Me'.freeze

  ADDIMAGEJS = <<-JS
    var elementFromSelector = document.querySelector('#illustration-modal-file');
    elementFromSelector.style.display='block';
    elementFromSelector.style.position='relative';
    elementFromSelector.style.top='-35px';
    elementFromSelector.style.zIndex= '99';
  JS

  page_click_link :select_upload_image, link_name: UPLOADIMAGE
  page_click_link :click_multiple_images, link_name: DOWNLOADMULIMAGES
  page_click_link :click_link_cancel, link_name: BasePage::CANCEL

  page_element :filters, FILTERS
  page_element :select_bulk_download, BULKDOWNLOADSELECT
  page_element :sort_by_ele, SORTBY
  page_element :filter_applied, FILTERBARSTATUS
  page_element :search_field, SEARCHFILED
  page_element :accept_terms_and_use_ele, ACCEPTTERMSANDUSE
  page_element :private_image_use, PRIVATEIMAGEUSE
  page_element :image_container, IMAGECONTAINER
  page_element :illusmodalimgstyletxt, ILLUSMODALIMGSTYLETXT
  page_element :illusmodalimgcategorytxt, ILLUSMODALIMGCATEGORYTXT
  page_element :illusmodalstylessearchfield, ILLUSMODALSTYLESSEARCHFIELD
  page_element :illusmodalcategorysearchfield, ILLUSMODALCATEGORYSEARCHFIELD
  page_element :illusmodalemaisearchfield, ILLUSMODALEMAILSEARCHFIELD

  page_elements :checkboxs, CHECKBOX
  page_elements :image_cards, IMAGECARDTITLE

  page_text_check :download_multiple_images, DOWNLOADMULIMAGES

  def upload_image(**options)
    footer_action = options[:footer_action] || 'Yes'
    popup_details = upload_image?
    return popup_details unless !!popup_details
    get_popupfooter_actions.find{|action| action.keys.include? footer_action}[footer_action].click
    fill_form_popup(options)
    accept_terms_and_use
    upload_to_sw
  end

  def fill_upload_form(options)
    footer_action = 'Yes'
    get_popupfooter_actions.find{|action| action.keys.include? footer_action}[footer_action].click if popup?
    fill_form_popup(options)
  end

  def download_multiple_images_options(select_all: nil, cancel: true)
    return false unless download_multiple_images?
    click_multiple_images
    available_options = select_bulk_download.all('option').map(&:text)
    click_link_cancel if cancel
    {options: available_options}
  end

  def image_page?
    parse_current_url.path == IMAGETAB && active_tab == IMAGES
  end

  def image_page
    navigate_to(IMAGES) unless image_page?
  end

  def upload_image?
    select_upload_image
    popup_content
  end

  def get_filters
    filters.all('li').map(&:text)
  end

  def add_filter(filter_name, value)
    select_filter(filter_name)
    search_for(value) unless get_filter_options.include? value
    within filters do
      select_checkbox(value)
    end
    select_filter(filter_name)
  end

  def select_checkbox(value)
    all(CHECKBOX).find{|ele|  ele.text.to_s == value.to_s}.click
  end

  #sort_using = ["Relevance", "New Arrivals", "Most Viewed", "Most Liked"]
  def sort_by(sort_using)
    sort_by_ele.select sort_using
  end

  def get_sort_by_options
    sort_by_ele.all('option').map(&:text)
  end

  def filters_applied
    filter_applied.all(SELECTEDFILTERS).map(&:text)
  end

  def all_image_details
    details = image_container.all(GRIDITEM).map do |image_web_ele|
      image_detail(image_web_ele)
    end
    {image_details: details, count: details.count}
  end

  def select_image(image_name: nil)
    has_css? IMAGECARDTITLE
    return image_cards.first.find(:xpath, '../..').click if image_name.is_a? NilClass
    page.find(IMAGECARDTITLE, text: image_name).find(:xpath, '../..').click
  end

  def select_first_image
    select_image(image_name: nil)
  end

  def first_image_name
    image_cards.first.text
  end

  def fill_form_popup(options={})
    return unless form_popup?
    avail_options = find('form').all('label').map(&:text)
    avail_options = avail_options.map(&:downcase).map{|ele| ele.gsub(' ', '_')}
    avail_options.map do |field_name|
      p field_name and next unless respond_to?("handle_#{field_name}", true)
      send("handle_#{field_name}", options[field_name])
      p "filled field_name of #{field_name}" 
      sleep WAIT2
    end
    fill_illustrator_details(options) if has_text? 'ILLUSTRATOR DETAILS'
    {title: options[:image_name] || DEFAULTIMAGENAME}
  end

  def fill_illustrator_details(options)
    handle_make_image_as_private
    handle_illustrator_email(options["IllustratorEmail"])
    handle_illustrator_first_name(options["IllustrtorFirstname"])
    sleep 10
    handle_illustrator_last_name
    handle_illustrator_about_me
  end

  def handle_illustrator_email(email = nil)
    email = DEFAULTEMAIL if email.is_a? NilClass
    find('label', text: EMAILID).find(:xpath, '..').click
    illusmodalemaisearchfield.set(:clear)
    illusmodalemaisearchfield.set(email)
    checkboxs.first.click
    sleep WAIT5
    find('label', text: EMAILID).find(:xpath, "..").click
  end

  def handle_illustrator_first_name(first_name = nil)
    first_name = DEFAULTFIRSTNAME if first_name.is_a? NilClass
    sw_text_field(field_name: FIRSTNAME, method: :set, field_value: first_name)
  end

  def handle_illustrator_last_name(last_name = nil)
    last_name = DEFAULTLASTNAME if last_name.is_a? NilClass
    sw_text_field(field_name: LASTNAME, method: :set, field_value: last_name)
  end

  def handle_illustrator_about_me(about_me = nil)
    about_me = DEFAULTABOUTME if about_me.is_a? NilClass
    send(get_type_of_sw(ABOUTME), field_name: ABOUTME, method: :set, field_value: about_me)
  end

  def handle_make_image_as_private
    private_image_use.set(true)
  end

  def upload_to_sw
    error = true
    sleep 10
    (upload_to_sw_button.click) if upload_to_sw?
    5.times.each do |num|
      return error unless form_popup?
      sleep num
    end
    sleep 15
    error
  end

  def accept_terms_and_use
    acc_ele = accept_terms_and_use_ele.find('input')
    acc_ele.set(true)
    sleep WAIT5
  end

  def select_download_multiple_image
    click_multiple_images if download_multiple_images?
    sleep WAIT5
    close_pop_up_notification
    find('input#bulk-download-images-select-all').click
    true
  end

  def avaliable_download_options
    select_bulk_download.all('option').map(&:text) 
  end

  def all_illus_title
    has_css? PBCARDTITLE
    all_image_details[:image_details].map{|image_detail| image_detail[:title]}  
  end

private

  def image_detail(web_ele)
    {
      title: web_ele.find(PBCARDTITLE).text,
      author: web_ele.all(PBCARDARTIST).map(&:text)
    }
  end

  def upload_to_sw?
    !upload_to_sw_button['class'].include? BUTTONDISABLED
  end

  def upload_to_sw_button
    find('a', text: UPLOADSTARTWEAVING)
  end

  def get_filter_options(filter_name=nil)
    select_filter(filter_name) if filter_name.kind_of? String
    return_array = []
    filters.all(CHECKBOX).each do |ele|
      return_array << (ele.text rescue '')
    end
    return_array
  end

  def search_for(filter)
    search_field.set filter
  end

  def select_filter(filter_name)
    within filters do
      click_link filter_name
    end
  end

  def form_popup?
    find(BasePage::MOALCONTAINER).has_css?('form', wait: 5) rescue 'false'
  end

  def handle_browse(file_details = nil)
    file_details ||= complete_file_path('burger-logo.png')
    page.execute_script(ADDIMAGEJS)
    attach_file(ILLUSMODALFILE, file_details)
  end

  def handle_image_name(image_name = nil)
    image_name = DEFAULTIMAGENAME if image_name.is_a? NilClass
    sw_text_field(field_name: IMAGENAME, method: :set, field_value: image_name)
  end

  def handle_image_style(style = nil)
    style ||= DEFAULTSTYLE
    return if illusmodalimgstyletxt[:value].downcase == style.downcase
    find('label', text: IMAGESTYLE).find(:xpath, '..').click
    illusmodalstylessearchfield.set(:clear)
    illusmodalstylessearchfield.set(style)
    checkboxs.first.click
    find('label', text: IMAGESTYLE).find(:xpath, '..').click
  end

  def handle_image_category(category = nil)
    category ||= DEFAULTCATEGORY
    return if illusmodalimgcategorytxt[:value] == category
    find('label', text: IMAGECATEGORY).find(:xpath, '..').click
    illusmodalcategorysearchfield.set(:clear)
    illusmodalcategorysearchfield.set(category)
    checkboxs.first.click
    find('label', text: IMAGECATEGORY).find(:xpath, '..').click
  end

  def handle_image_license(license = true)
    license
  end
end