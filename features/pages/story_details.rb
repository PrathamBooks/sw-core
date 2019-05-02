class StoryDetails < BasePage

  ACTIONNOTAVAILABLE = "%s action not Available, Available options are: %s"
  LOGINREQUIRED = 'Login Required to do Action'.freeze
  
  READSTORY = "Read Story".freeze
  BOOKTITLE = '.pb-book__title'.freeze
  CONTENT = '.pb-book__content'.freeze
  STORYCOVER = '.pb-book__cover-wrapper'.freeze
  RECOMMENDED = '.pb-book-card__recommendation'.freeze
  LIKES = '.pb-book__likes'.freeze
  DROPDOWN = '.pb-dropdown__contents'.freeze
  EMPTYHEART = '.pb-svg-icon--type-heart-outline'.freeze
  BOOKSTATS = '.pb-book__stats'.freeze
  BOOKVIEWS = '.pb-stat__value'.freeze
  ADDTOMYBOOKSHELF = 'Add to My Bookshelf'.freeze
  DELETEBOOKSHELF = 'Delete from My Bookshelf'.freeze
  DOWNLOAD = 'Download'.freeze
  SHARE = 'Share'.freeze
  TRANSLATE = 'Translate'.freeze
  REPORT = 'Report'.freeze
  MORE = 'More'.freeze
  AVAILABLEACTIONS = [ADDTOMYBOOKSHELF, DELETEBOOKSHELF, DOWNLOAD, SHARE, TRANSLATE, REPORT, MORE].freeze
  SAVETOOFFLINE = 'Save to offline library'.freeze
  SIMILARSTORIES = '.pb-section-block__content .pb-cards-carousel .slider-frame'.freeze
  STORYTITLE = '.pb-book-card__title'.freeze
  STORYLEVELSTRIP = '.pb-book-card__level-strip'.freeze
  STORYLEVEL = '.pb-book-card__level'.freeze
  STORYLANGUAGE = '.pb-book-card__language'.freeze
  CARDMETA = '.pb-book-card__meta'.freeze
  STORYAUTHORS = '.pb-book-card__names'.freeze
  TEXTBOX = '.pb-text-field__input'.freeze
  DEFAULTCOMMENT = "Need to improve".freeze
  FOOTER = '.pb-modal__footer'.freeze

  def story_details?
    path_details = parse_current_url.path.split('/')
    return false if path_details.count != 3
    storyIdTitle = path_details.last.gsub("-","").downcase
    url_check = ( (path_details[0] == "") && (path_details[1] == "stories") )
    url_check && !!(storyIdTitle.match /\A([0-9]*)+[a-z]+\.?[a-z]/)
  end
  
  def click_firststory(title)
    find("a", :text => title).trigger('click')
  end

  def story_title
    page.find(CONTENT).find(BOOKTITLE).text
  end

  def translate_detail?
    validation_url=parse_current_url.path.split('/')
    return false if validation_url.count != 5
    translate_storyno = validation_url.last.gsub("-","").downcase
    url = ((validation_url[0]=="") && (validation_url[1]=='v0') && (validation_url[2]=="editor") && (validation_url[3]=="story"))
    url && !!(translate_storyno.match /\A([0-9]*)+[a-z]+\.?[a-z]/)
    return url
  end

  def get_likes
    find(STORYCOVER).find(LIKES).text.to_i
  end

  def like_story(raise_error=false)
    return_flag = true
    intial_like_count = get_likes
    find(EMPTYHEART).click
    wait_for_loader
    updated_like_count = get_likes
    if intial_like_count == updated_like_count
      return_flag = false
      login_dropdown(raise_error) if (has_css? DROPDOWN) && page.find(DROPDOWN).all('a').map(&:text).empty?
    end
    return_flag
  end

  def story_popup_actions
    return_array = []
    if (has_css? DROPDOWN)
     return_array = page.find(DROPDOWN).all('a').map(&:text)
   end
    return_array
  end

  def login_signup_popup
    return_array = []
    if has_css? DROPDOWN 
      return_array = page.find(DROPDOWN).all('a').map(&:text)
      span_text = page.find(DROPDOWN).all('span').map(&:text)
      return_array.each_with_index do |text_present, index|
        return_array[index] = text_present.gsub(span_text[index], "").strip
      end
    end
    return_array
  end 

  def report_filter(value)
    find('.pb-modal__bounds').all('.pb-checkbox__label').find{|ele|  ele.text.to_s == value.to_s}.click
    if has_css? TEXTBOX
      find('.pb-modal__bounds').find('.pb-text-field__input').set DEFAULTCOMMENT 
    end
    select_report
    wait_for_loader
  end

  def select_report()
    within FOOTER do
      click_link 'Report'
    end
  end

  def liked?
    !has_css? EMPTYHEART
  end

  def get_views_count
    find(BOOKSTATS).all(BOOKVIEWS).last.text.to_i
  end

  def recommended?
    page.has_css?(STORYCOVER+" "+RECOMMENDED)
  end

  def story_details
    details = {}
    within STORYCOVER do
      within STORYLEVELSTRIP do
        details[:language] = find(STORYLANGUAGE).text
        details[:level] = find(STORYLEVEL).text
      end
      within CARDMETA do
        details[:title] = find(STORYTITLE).text
        details[:authors] = all(STORYAUTHORS).map(&:text)
      end
    end
    details[:views] = get_views_count
    details[:recommended] = recommended?
    details[:likes] = get_likes
    details[:is_liked] = liked?
    details
  end
  
  def read_story
    find(CONTENT).click_link READSTORY
  end

  def similar_stories
    return_hash = {}
    within SIMILARSTORIES do
      cards = all(STORYTITLE)
      return_hash[:titles] = cards.map(&:text)
      return_hash[:count] = cards.count
    end
    return_hash
  end

  def story_actions(action_name)
    upated_action = AVAILABLEACTIONS.select{|act| act.downcase == action_name.downcase}.first
    return ACTIONNOTAVAILABLE % [action_name, AVAILABLEACTIONS.join(',')] unless story_actions_available.include? upated_action
    within find(CONTENT) do
      click_link upated_action
    end
  end

  def has_action?(action_name)
    within find(CONTENT) do
      return has_text?(action_name)
    end
  end

  def edit_story
    click_on 'More'
    click_on 'Edit'
    click_on 'Yes'
  end

  private
  #Need to handle in future
  def login_dropdown(raise_error_flag)
    if raise_error_flag
      return { error: LOGINREQUIRED, status: false} 
    end
    false
  end

  def story_actions_available
    within find(CONTENT) do
      all('li').map(&:text)
    end
  end

end