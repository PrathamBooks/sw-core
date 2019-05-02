class ListPage < BasePage
  
  FILTERS = '.pb-filters-bar__action-wrapper'.freeze
  LISTS ='Lists'.freeze
  ALLLISTS = '.pb-all-lists'.freeze
  STORYGRID = '.grid__container'.freeze
  GRIDITEM = '.pb-grid__item'.freeze
  LISTNAMEERROR = 'Please select the Available Lists in list page : %s'.freeze
  LISTLIKES = '.pb-reading-list__likes'.freeze
  LISTEMPTYHEART = '.pb-svg-icon--type-heart-outline'.freeze
  LOGINORSIGNUPREQUIRED = 'Login or signup is Required to do Action'.freeze
  LISTSTORYERROR = 'Please select the Available stories present in the given list : %s'
  PUBLISHEDPOPUPMESSAGE = "Thank you very much for your feedback."
  DROPDOWN = '.pb-dropdown__contents'.freeze
  LISTBOOKS ='.pb-stat--icon-default'.freeze
  LISTREADCOUNT = '.pb-stat__value'.freeze
  ALLSTORIES = '.pb-reading-list-entry__link'.freeze
  CHECKBOX = '.pb-checkbox__label'.freeze
  ALLLISTSNAMES = '.pb-reading-list-card__title'.freeze
  SAVETOOFFLINE = 'Save to offline library'.freeze
  LISTDOWNLOAD ='Download'.freeze
  LISTSHARE = 'Share'.freeze
  DELETEFOOTERPOPUP = '.pb-modal__footer'.freeze
  POPUP = '.pb-modal__bounds'.freeze
  AVAILABLEACTIONS = [SAVETOOFFLINE, LISTDOWNLOAD, LISTSHARE].freeze
  CHECKBOX = '.pb-checkbox__label'.freeze
  CONTENT = '.pb-reading-list__action-bar.pb-action-bar--3up'.freeze
  ACTIONNOTAVAILABLE = "%s action not Available, Available options are: %s".freeze
  LISTCREATORERROR = 'Please select the Available publisher name in list page : %s'.freeze
  LISTSORTBY = '#filters-bar-sort-by'.freeze
  LISTPOPUP = '.pb-modal__bounds'.freeze
  LISTFEEDBACKPOPUP = '.pb-modal__header'.freeze
  LISTFORM = '.pb-modal__footer'
  FLOATINGACTIONS = '.pb-floating-actions-bar__container'.freeze
  ALLFORMS ='.freebirdFormviewerViewItemsItemItemHeader'.freeze
  FORMSUBMIT = '.quantumWizButtonPaperbuttonLabel.exportLabel'.freeze
  RESPONSEELEMENT = '.freebirdFormviewerViewResponseConfirmationMessage'.freeze
  LISTEDITACTIONS = 'please select available options : %s'.freeze
  LISTEDITBOOKS = '.pb-reading-list-entry--edit-active'.freeze
  STORYNAMEENTRY = '.pb-reading-list-entry__content'.freeze
  ALLSTORIES = '.pb-reading-list-entry__title'.freeze
  ENTRTFOOTER = '.pb-reading-list-entry__footer'.freeze
  DEFAULTACTION ='Yes'.freeze
  TEXTAREA ='.pb-text-field__input'.freeze
  CONTAINER = '.pb-reading-list-entry__content'.freeze
  LISTDESCRIPTIONID = '#reading-list-list-desc-input'.freeze
  LISTDESWRAPPER = '.pb-reading-list__wrapper'.freeze

  def list_page?
    path_details = parse_current_url.path.split('/')
    return false if path_details.count != 2
    url_check = ( (path_details[0] == "") && (path_details[1] == "lists") )
  end

  def get_list_likes
    find(LISTLIKES).text.to_i
  end

  def navigate_to_list_page
    navigate_to( LISTS)
  end

  def get_list_reads
    find(LISTBOOKS).find(LISTREADCOUNT).text.to_i
  end

  def list_actions(action_name)
    upated_action = AVAILABLEACTIONS.select{|act| act.downcase == action_name.downcase}.first
    return ACTIONNOTAVAILABLE % [action_name, AVAILABLEACTIONS.join(',')] unless list_actions_available.include? upated_action
    within find(CONTENT) do
      click_link upated_action
    end
  end

  def list_actions_available
    within find(CONTENT) do
      all('li').map(&:text)
    end
  end

  def get_listsort_by_options
    find(LISTSORTBY).all('option').map(&:text)
  end

  def get_filters
    find(FILTERS).all('li').map(&:text)
  end

  def all_lists
    within ALLLISTS do
      all(ALLLISTSNAMES).map(&:text)
    end
  end

  def choose_list_created(publisher_name)
    creator_name = find(CONTENT).all('a')[1].text
    name = creator_name.include? publisher_name
    raise LISTCREATORERROR % creator_name if creator_name.include? publisher_name
    find(CONTENT).all('a')[1].click
    sleep WAIT3
  end
   
  def select_option(title)
    find("a", :text => title).click
  end

  def choose_listname(list_name)
    ele = all_lists.include? list_name
    raise LISTNAMEERROR % all_lists.join(", ") if ele == 'false'
    select_option(list_name)
    sleep WAIT5
  end

  def get_stories_list
    all(ALLSTORIES).map(&:text)
  end

  def list_popup_actions
    if (has_css? DROPDOWN)
     return_array = page.find(DROPDOWN).all('a').map(&:text)
   end
  end

  def validation_feedback
    return_flag=false
    message=find(RESPONSEELEMENT).text
    message.gsub(" ","")
    if message == PUBLISHEDPOPUPMESSAGE
      return_flag = true
    end
    return_flag
  end

  def list_details?
    path_details = parse_current_url.path.split('/')
    return false if path_details.count != 3
    list_name = path_details.last.gsub("-","").downcase
    url_check = ( (path_details[0] == "") && (path_details[1] == "lists") )
    url_check && !!(list_name.match /\A([0-9]*)+[a-z]+\.?[a-z]/)
  end

  def choose_story(story_name)
    name = get_stories_list.include? story_name
    raise LISTSTORYERROR % get_stories_list.join(",") if name == 'false'
    select_liststory(story_name)
  end

  def select_liststory(title)
    find('a.pb-reading-list-entry__link', :text => title).click
  end

  def select_checkbox(value)
    all(CHECKBOX).find{|ele|  ele.text.to_s == value.to_s}.click
  end

  def categories_list
    all(CHECKBOX).map(&:text)
  end

  def select_filter(filter_name)
    within find(FILTERS) do
      click_link filter_name
    end
  end

  def organization_page?
    path_details = parse_current_url.path.split('/')
    return false if path_details.count != 3
    org = path_details.last.gsub("-","").downcase
    url_check = ( (path_details[0] == "") && (path_details[1] == "users") )
    url_check && !!(org.match /\A([0-9]*)+[a-z]+\.?[a-z]/)
  end

  def like_list(raise_error=false)
    return_flag = true
    intial_like_count = get_list_likes
    find(LISTEMPTYHEART).click
    sleep WAIT3
    updated_like_count = get_list_likes
    if intial_like_count == updated_like_count
      return_flag = false
      login_signup_dropdown(raise_error) if (has_css? DROPDOWN) && page.find(DROPDOWN).all('a').map(&:text).empty?
    end
    return_flag
  end

  def list_feedback?
    has_css? LISTFEEDBACKPOPUP
  end

  def choose_list_popup
    within LISTFORM  do
      click_link 'Click Here'
    end
    sleep WAIT5
    page.driver.switch_to_window(page.driver.browser.window_handles.last)
  end

  def get_mandatory_fileds_listfeedbakform
    available_fields = all(ALLFORMS).map(&:text)
    to_fill_elements = available_fields.select{|x| x.end_with? '*'}
    to_fill_elements.map{|ele| ele.gsub('*', '')}.map(&:strip)
  end

  def fill_sheet
   find('.freebirdFormviewerViewItemList').all('div[role=listitem]').each do |list_item|
     list_item.all('label')[1].click rescue "Not entered"
    end
    form_submit
  end

  def form_submit
    find(FORMSUBMIT).click
  end

  def login_signup_dropdown(raise_error_flag)
    if raise_error_flag
      return { error: LOGINORSIGNUPREQUIRED, status: false}
    end
    false
  end
end