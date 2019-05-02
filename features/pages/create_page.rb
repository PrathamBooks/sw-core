class CreatePage < BasePage

  CREATEPOPUP = '.simple_form .newStory'.freeze
  IMAGESEARCH = '#ill_search_query'.freeze
  PAGESIDEBAR = '.float-left .sc-sidebar-page-block'.freeze
  VALIDATIONPOPUP = '.ui-widget'.freeze
  STORYLANGID = 'story_language_id'.freeze
  STORYCATEGORIES = '.story_categories'.freeze
  COPYRIGHT = '#story_copy_right_year'.freeze
  AUTHOREMAIL = '#story_authors_attributes_0_email'.freeze
  AUTHORFIRSTNAME = '#story_authors_attributes_0_first_name'.freeze
  STORYTITLE = '#story_title'.freeze
  STORYSYNOPSIS = '#story_synopsis'.freeze
  DELETEPAGE = '#delete_page'.freeze
  DUPLICATEPAGE = '#duplicate_page'.freeze
  MODALBODYAPP = '.modal-body-app'.freeze
  PUBLISH = '#publish'.freeze
  PUBLISHBOOK = '#publish-book'.freeze
  PUBLISHSTORY = '#publish_story'.freeze
  OPENIMAGEDRAWER = '#open_image_drawer'.freeze
  PAGESRIBBON = '#pages_ribbon'.freeze
  SORTABLE = '#sortable'.freeze
  INSERTPAGE = '#insert_page'.freeze
  NOOFPAGES = '#numberOfPages'.freeze
  STORYHEADING = 'div.heading-title'.freeze
  CLOSEIMAGEDRAWER = '.modal-body button.close'.freeze
  IMGCARDCONTENT = '.img-card-content'.freeze
  TOURHELP = '#tour_help'.freeze
  SHEPHERDCONTENT = '.shepherd-content'.freeze
  ILLUSHOLDER = '#illustration-holder'.freeze
  IMGCARDIMG = '.img-card-img'.freeze
  ORDINARYPAGE = '.page-list #sortable'.freeze
  TXTEDITOR = '#txtEditor'.freeze
  ILLUSCONTAINER = '#illustration_container'.freeze
  IMAGEERRORS = 'div#image_errors'.freeze
  IMGERRORTITLE = 'span.ui-dialog-title'.freeze
  DELLASTSTORYPAGE = '#delete_last_story_page_dialog'.freeze
  DELPAGEDIALOG = '#delete_page_dialog'.freeze
  FLASHERROR = '#flash_error'.freeze
  SAVE = '#save'.freeze
  COVERS = '.covers'.freeze
  ICNTRLSAVE = 'i.cropControlSave'.freeze
  INSERTPAGES = 'span#insert_pages'.freeze
  PREVIEW = 'a#preview'.freeze
  NEXTPAGE = '.next-page'.freeze
  CLOSEBUTTON = '#close-button'.freeze

  NONE = 'None'.freeze
  STORYSORTOPT = 'StorySortOptions'.freeze
  BROWSEALLIMAGES = 'browse all images'.freeze
  SAVETOFAV = 'save to favourites'.freeze
  ILLUSTRATIONCATEGORY ='.illustration_categories'.freeze
  ILLUSTRATIONSTYLE ='.illustration_styles'.freeze
  ILLUSTRATIONLICID ='illustration_license_type'.freeze
  TERMS = '#checkbox-terms-of-use'.freeze
  ADDTOCURRENTPAGE = 'add to current page'.freeze
  DEFAULTTITLE = 'SW-Automation'.freeze
  DEFAULTCONTENT = 'This is default content for the story created via Automation'.freeze
  DEFAULTSYNOPSYS = 'Triggered via Automation, Sanity check'.freeze
  DEFAULTLANG = 'English'.freeze
  DEFAULTORIENTATION = 'landscape'.freeze
  DEFAULTLEVEL = 1.freeze
  DEFAULTCATEGORY = 'Activity Books'.freeze
  DEFAULTCOPYRIGHT = 2018.freeze
  DEFAULTEMAIL = 'user@sample.com'.freeze
  DEFAULTFIRSTNAME = 'user'.freeze
  TOOLTIP = 'Welcome to our new story creator!'.freeze
  TOOLTIPDATABANK = [['Welcome to our new story creator!', 'NEXT'],
                     ['Image Drawer', 'NEXT'],
                     ['Add to favourites', 'NEXT'],
                     ['Formatting','NEXT'],
                     ['Layouts', 'NEXT'],
                     ['Add a working title', 'NEXT'],
                     ['Start Over', 'DONE']
                    ].freeze
  CREATEPOPUPOPTIONS = ["Horizontal", "Vertical", 'Level 1:', 'Easy words, word repetition, less than 250 words',
                        'Level 2:', 'Simple concepts, upto 600 words', 'Level 3:', 'Longer sentences, upto 1500 words',
                        'Level 4:', 'Longer, more nuanced stories, more than 1500 words' ].freeze
  CREATENEWBOOK = 'Create New Book'.freeze
  CREATE = 'Create'.freeze
  IMAGEPRESENT = 'Image Already Added'.freeze
  CREATORMENU = 'story creator menu'.freeze
  PUBLISHERPOPUPFILLING = "Following fields in Publisher Popup will be filled - %s"
  PUBLISHPOPUPTEXT = 'Edit your Story Card image'.freeze
  FAVOURITES = 'favourites'.freeze
  UNABLETOCLOSETOOLTIP = 'Unable to close Tool Tip'.freeze
  TOOLTIPERROR = 'Tool Tip error'.freeze
  OK = 'Ok'.freeze
  ADDANIMAGE = 'add an image'.freeze
  STARTWITHWORDS = 'start with words'.freeze
  DEFAULTILLUSTRATIONTITLE = 'Storyweaver'.freeze
  DEFAULTILLUSTRATIONCATEGORY = 'Animals & Birds'.freeze
  DEFAULTILLUSTRATIONSTYLE = 'Cartoony'.freeze
  DEFAULTILLUSTRATIONTAGNAME ='story'.freeze
  DEFAULTILLUSTRATIONLICENSE ='CC BY 4.0'.freeze
  DEFAULTILLUSTRATIONEMAIL = 'content_manager@sample.com'.freeze
  DEFAULTILLUFIRSTNAME = 'content_manager'.freeze
  DEFAULTILLULASTNAME = 'sample'.freeze
  DEFAULTILLUSTRATIONIMAGE ='image_10'.freeze

  def navigate_to_create_page
    click_link CREATE
  end

  def create_page?
    has_text? CREATENEWBOOK
  end

  def create_popup_options?(options)
    result = true
    options.each do |option_name|
      result &&= has_text? option_name
    end
    result && other_options
  end

  def other_options
    CREATEPOPUPOPTIONS.map do |text|
      has_text? text
    end.uniq.inject{ |ele,result=true| result &&= ele }
  end

  def create_pop_cancel
    find('.btn-link-underline', :text => 'Cancel', exact: true).click
    sleep WAIT2
  end

  def create_book_with(start_with = STARTWITHWORDS, lang: DEFAULTLANG, title: DEFAULTTITLE, level: DEFAULTLEVEL, orientation: DEFAULTORIENTATION)
    create_page?
    within find(MODALBODYAPP, wait: WAIT5) do
      choose_language(lang)
      fill_title(title)
      choose_reading_level(level)
      choose_orientation(orientation)
      click_button start_with
      sleep WAIT2
    end
    handle_tool_help
    {start_with: start_with, language: lang, title: title, level: level, orientation: orientation}
  end

  #sort: ['None', 'New Arrivals', 'Most Viewed', 'Most Liked']
  def add_image_from_popup(search: nil, sort: NONE)
    return IMAGEPRESENT if image_already_present?
    select_add_image unless image_popup?
    NilClass === search ? clear_search : search_for_image(search)
    sort_image_filter(sort) if sort != NONE
    select_first_image
    sleep WAIT2
  end

  def handle_tool_help
    find('h3',:text => TOOLTIP, wait: WAIT5).find(:xpath, '..').find('a').click rescue p UNABLETOCLOSETOOLTIP
  end

  def add_pages(pages_count)
    pages_count = pages_count.to_i
    page_side_bar do
      find(INSERTPAGES).click
      inital_count = find(NOOFPAGES)[:value].to_i
      counter, button_name = if inital_count > pages_count
        [ inital_count - pages_count, 'minus' ]
      else
        [ pages_count - inital_count, 'add']
      end
      counter.times { find("button[name=#{button_name}]").click}
      find(INSERTPAGE).click
    end
  end

  def add_content_to_page
    find('span', :text => CREATORMENU).click if has_text? CREATORMENU
    no_of_pages = total_pages_count
    no_of_pages.times do |page_number|
      if page_number == 0
        handle_front_cover
        next
      end
      if page_number == no_of_pages-1
        handle_back_cover
        next
      end
      handle_ordinary_page(page_number)
      sleep WAIT2
    end
  end

  def preview_story
    find(PREVIEW).click
    sleep WAIT2
    pages_count = 0
    within find('.modal-body') do
      until !has_css? NEXTPAGE do
        find(NEXTPAGE).click
        sleep WAIT1
        pages_count += 1
      end
    end
    find(CLOSEBUTTON).click
    {pages_count: pages_count}
  end

  def publish_story(options = {})
    return_hash = {}
    sleep WAIT3
    navigate_to_publish_popup
    return_hash = fill_publish_popup(options[:publish] || {})
    find('#next').click
    find(PUBLISHSTORY).click
    return_hash
  end

  def navigate_to_publish_popup
    find(PUBLISH).click
    sleep WAIT4
    return validation_message if !(has_text? PUBLISHPOPUPTEXT) && validation_popup?
    find('#storycard-img-edit-done').click
    sleep WAIT2
    find(PUBLISHBOOK).click
  end

  def get_mandatory_publish_popup_fields
    available_fields = find(MODALBODYAPP).all('label').map(&:text)
    to_fill_elements = available_fields.select{|x| x.start_with? '*'}
    to_fill_elements.push('EMAIL', 'First NAME') if available_fields.include? "Email"
    to_fill_elements.map{|ele| ele.gsub('*', '')}.map(&:strip)
  end

  def fill_publish_popup(publish_options)
    sleep WAIT2
    available_fields = find(MODALBODYAPP).all('label').map(&:text)
    to_fill_elements = available_fields.select{|x| x.start_with? '*'}
    to_fill_elements.push('Email', 'First Name') if available_fields.include? "Email"
    to_fill_elements = to_fill_elements.map{|ele| ele.gsub('*', '')}.map(&:strip).map do |ele|
                          ele.downcase.gsub(' ', '_')
                        end
    p PUBLISHERPOPUPFILLING % to_fill_elements.join(' , ')
    to_fill_elements.each do |ele_name|
      send("fill_publisher_#{ele_name}", publish_options[ele_name.to_sym])
      sleep WAIT1
    end
    {fields: available_fields, fields_filled: to_fill_elements}
  end

  def open_image_drawer
    find("##{__method__}").click
  end

  def close_image_drawer
    find(CLOSEIMAGEDRAWER).click
  end

  def delete_page(confirmation: true)
    page_side_bar do
      find(DELETEPAGE).click
    end
    delete_page_validation if confirmation
  end

  def save_story
    find(SAVE).click
  end

  def duplicate_page
    page_side_bar do
      find(DUPLICATEPAGE).click
    end
  end

  def check_favourites
    open_favourites
    get_favourite_details
  end

  def get_favourite_details
    return_data_hash = {image_count: 0, images: []}
    within find(ILLUSHOLDER) do
      return_data_hash[:images] = all('.img-card-wrap').map do |web_ele|
        return_data_hash[:image_count] += 1
        favourite_details(web_ele)
      end
    end
    return_data_hash
  end

  def favourite_details(web_ele)
    image_name, owner = web_ele.find(IMGCARDCONTENT).all('span').map(&:text)
    {image_name: image_name, owner: owner }
  end

  def add_first_image_to_favourites
    image_name = ""
    find(OPENIMAGEDRAWER).click unless image_popup?
    click_link BROWSEALLIMAGES
    sleep WAIT2
    find(ILLUSHOLDER).all(IMGCARDIMG,wait: 5).first.hover
    sleep WAIT2
    find(ILLUSHOLDER).all(IMGCARDIMG, wait: 5).first.all('div', text: SAVETOFAV, exact: true, visible: false).last.click
    sleep WAIT2
    image_name = find(ILLUSHOLDER).all(IMGCARDCONTENT, wait: 5).first.all('span').map(&:text).first
    find('button.close').click
    image_name
  end

  def open_favourites
    counter =0
    until image_popup?
      find(OPENIMAGEDRAWER, wait: WAIT5).click
      sleep WAIT2
      raise 'Unable to open Image Drawer' if counter == 5
      counter += 1
    end
    click_link FAVOURITES
  end

  def remove_image_from_favourites
    open_favourites
    find(ILLUSHOLDER).all(IMGCARDIMG,wait: 5).first.hover
    sleep WAIT2
    image_name = find(ILLUSHOLDER).all(IMGCARDCONTENT, wait: 5).first.all('span').map(&:text).first
    find(ILLUSHOLDER).all(IMGCARDIMG, wait: 5).first.all('div', text: 'remove from favourites', exact: true, visible: false).last.click
    sleep WAIT2
    image_name
  end

  def select_help
    find(TOURHELP).click
  end

  def validate_tour_help
    select_help unless has_css? SHEPHERDCONTENT
    TOOLTIPDATABANK.each do |data_bank|
      raise TOOLTIPERROR unless has_text? data_bank.first
      find('a.shepherd-button', :text => data_bank.last).click
    end
  end

  def edit_book
    find("##{__method__}").click
  end

  def change_title_inedit(updated_title)
    within find(BasePage::MODALCONTENT) do
      find(STORYTITLE).set updated_title
      find('#save_book_info', wait: WAIT5).click
    end
  end

  def get_title_create_page
    find(STORYHEADING).text rescue ''
  end

  def flash_error?
    has_css? FLASHERROR
  end

  def flash_error
    find(FLASHERROR).text
  end

  def choose_language(lang)
    select(lang, :from => STORYLANGID, wait: WAIT5)
  end

  def fill_title(title)
    find(STORYTITLE).set title
  end

  def choose_reading_level(level)
    level_id = "story_reading_level_#{level}"
    choose level_id
  end

  def choose_orientation(orientation)
    orientation_id = "story_orientation_#{orientation}"
    choose orientation_id
  end

  def image_pop
    within find('.modal--story-creator') do
      yield
    end
  end

  def select_add_image
    find('#selected_page', wait: 5).find('span', :text => ADDANIMAGE ).click
    sleep WAIT5
  end

  def image_popup?
    has_css? '.modal--story-creator'
  end

  def search_for_image(search_key)
    image_pop do
      search_ele = find(IMAGESEARCH)
      search_ele.set search_key
      search_key.find(:xpath, '../..').find('.input-group-addon').click
    end
  end

  def sort_image_filter(sort_by)
    image_pop { select(sort_by, :from => STORYSORTOPT) }
  end

  def select_first_image
    sleep WAIT2
    find(ILLUSHOLDER).all(IMGCARDIMG,wait: 5).first.hover
    sleep WAIT2
    find(ILLUSHOLDER).all(IMGCARDIMG, wait: 5).first.all('div', text: ADDTOCURRENTPAGE, exact: true, visible: false).last.click
    sleep WAIT2
    find(ICNTRLSAVE, wait: 5).click
  end

  def page_side_bar
    within find(PAGESIDEBAR) do
      yield
    end
  end

  def validation_popup?
    has_css? VALIDATIONPOPUP
  end
 
  def validation_message
    return_data = { error: true, title: '', message: ''}
    within find(VALIDATIONPOPUP) do
      return_data[:title] = find(IMGERRORTITLE).text
      return_data[:message] = find(IMAGEERRORS).text
      click_button OK
    end
    return_data
  end

  def delete_page_validation
    ok_button = ''
    msg = if has_css? DELLASTSTORYPAGE
            ok_button = OK
            find(DELLASTSTORYPAGE).text
          else
            ok_button = 'Confirm'
            find(DELPAGEDIALOG).text
          end
    return_hash = {title: find(IMGERRORTITLE).text ,
                    message: msg}
    find('button', :text => ok_button, exact: true).click
    return_hash
  end

  def total_pages_count
    find(PAGESRIBBON).find(SORTABLE).all('a').count + 2 #Frontcover and Backcover
  end

  def handle_front_cover
    page_side_bar do
      all(COVERS).first.all('a').first.click
    end
    add_image_from_popup
  end

  def handle_back_cover
    page_side_bar do
      all(COVERS).last.all('a').first.click
    end
    sleep WAIT2
  end

  def handle_ordinary_page(page_number)
    correction = 1
    page_side_bar do
      within find(ORDINARYPAGE) do
        all('a')[page_number-correction].click
      end
    end
    sleep WAIT2
    add_image_from_popup
  end

  def image_already_present?
    find(ILLUSCONTAINER).has_css? 'img'
  end

  def clear_search
    find('span', :text =>'Clear').click
  end

  def text_editor(text = DEFAULTCONTENT)
    all(TXTEDITOR).each do |ele|
      ele.find('span').set text
    end
  end

  def publish_popup
    within find(MODALBODYAPP) do
      yield
    end
  end

  def fill_publisher_story_title(title)
    title = DEFAULTTITLE if NilClass === title
    return find(STORYTITLE).set "" if title == :skip
    publish_popup do
      ele = find(STORYTITLE)
      ele.set title if ele.value.length.zero?
    end
  end

  def fill_publisher_synopsis(synopsis)
    synopsis = DEFAULTSYNOPSYS if NilClass === synopsis
    publish_popup do
      find(STORYSYNOPSIS).set synopsis
    end
  end

  def fill_publisher_reading_level(level)
    level = DEFAULTLEVEL if NilClass === level
    publish_popup do
      choose_reading_level(level)
    end
  end

  def fill_publisher_category(category)
    category = DEFAULTCATEGORY if NilClass === category
    publish_popup do
      find(STORYCATEGORIES).click
      find(STORYCATEGORIES).all('li').find{|x| x.text == category }.click
      find(STORYCATEGORIES).click
    end
  end

  def fill_publisher_copyright_year(copyright)
    copyright = DEFAULTCOPYRIGHT if NilClass === copyright
    find(COPYRIGHT).select copyright
  end

  def fill_publisher_email(email)
    email = DEFAULTEMAIL if NilClass === email
    publish_popup do
      find(AUTHOREMAIL).set email
    end
  end

  def fill_publisher_first_name(first_name)
    first_name = DEFAULTFIRSTNAME if NilClass === first_name
    publish_popup do
      find(AUTHORFIRSTNAME).set first_name
    end
  end

  def image_title(image_name)
    image_name = DEFAULTILLUSTRATIONTITLE if image_name.kind_of? NilClass
    find('#illustration_name').set image_name
  end
  
  def category(category_name)
    category_name = DEFAULTILLUSTRATIONCATEGORY if category_name.kind_of? NilClass
    find(ILLUSTRATIONCATEGORY).click
    find(ILLUSTRATIONCATEGORY).all('li').find{|x| x.text == category_name}.click
    find(ILLUSTRATIONCATEGORY).click
  end

  def image_style(style_name)
    style_name = DEFAULTILLUSTRATIONSTYLE if style_name.kind_of? NilClass
    find(ILLUSTRATIONSTYLE).click
    find(ILLUSTRATIONSTYLE).all('li').find{|x| x.text == style_name}.click
    find(ILLUSTRATIONSTYLE).click
  end

  def image_license(image_license)
    image_license = DEFAULTILLUSTRATIONLICENSE if image_license.kind_of? NilClass
    find('.illustration_license_type').select(image_license)
  end

  def illustration_choose_image(image_name)
    image_name = DEFAULTILLUSTRATIONIMAGE if image_name.kind_of? NilClass
    script = "$('#file-profile-upload').css({display: 'block'});"
    page.execute_script(script)
    image_file_name = Rails.root.to_s + "/illustrations/#{image_name}.jpg"
    attach_file('illustration[image]', image_file_name)
  end

  def illustrator_email(email)
    email = DEFAULTILLUSTRATIONEMAIL if email.kind_of? NilClass
    find('#illustration_illustrators_attributes_0_email').set email
  end

  def illustratorFirst_Name(first_name)
   first_name = DEFAULTILLUFIRSTNAME if first_name.kind_of? NilClass
   find('#illustration_illustrators_attributes_0_first_name').set first_name
  end

  def illustratorlast_name(last_name)
    last_name = DEFAULTILLULASTNAME if last_name.kind_of? NilClass
    find('#illustration_illustrators_attributes_0_last_name').set last_name
  end

  def illustration_accept_terms
    find(TERMS).click
  end

  def upload_image
   click_button 'upload'
  end

  def validation_illustration
    find('#myModalLabel').text 
  end
 
  def fill_illustration_popup(illustration_options={})
    sleep WAIT5
    important_fields = find('.modal-body-app').all('.label-required').map(&:text).map(&:downcase).map{|c| c.gsub(" ", "_")}
    important_fields.push('illustration_choose_image')
    if has_text? 'Email'
     important_fields.push('illustrator_email','illustratorFirst_Name','illustratorlast_name')
    end
    important_fields.each do |ele_name|
     send("#{ele_name}",illustration_options[ele_name.to_sym])
     sleep WAIT2
    end
  end

 def illustration_publish()
    illustration_accept_terms
    upload_image
    sleep WAIT3
    flash_error? ? flash_error : validation_illustration
 end

 def get_mandatory_editorimage_popup_fields
    sleep WAIT5
    important_fields = find('.modal-body-app').all('.label-required').map(&:text)
    important_fields.push('EMAIL','ILLUSTRATOR FIRST NAME','ILLUSTRATOR LAST NAME') if has_text? 'Email'
    important_fields
  end
end
