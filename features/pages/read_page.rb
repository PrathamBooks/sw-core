class ReadPage < BasePage
  
  URLPATH = '/stories'.freeze
  FILTERS = '.pb-filters-bar__action-wrapper'.freeze
  FILTERTAG = '.pb-link .pb-link--default'.freeze
  CHECKBOX = '.pb-checkbox__label'.freeze
  SEARCH = '.pb-picklist__header .pb-text-field__input'.freeze
  FILTERBARSTATUS = '.pb-filters-bar__status'.freeze
  SELECTEDFILTERS = '.pb-filters-bar__pill'.freeze
  SORTBY = '#filters-bar-sort-by'.freeze
  STORYCARDLINK = 'a.pb-book-card__link'.freeze
  TITLE = '.pb-book-card__title'.freeze
  RECOMMENDATION = '.pb-book-card__recommendation'.freeze
  LANGUAGE = '.pb-book-card__language'.freeze
  LEVEL = '.pb-book-card__level'.freeze
  VIEWS = '.pb-book-card__footer .pb-stat__value'.freeze
  TRANSLATEDILLUSTRATED = '.pb-book-card__meta .pb-book-card__names'.freeze
  LOADMORE = 'Load More'.freeze
  STORYCOUNT = '.pb-filters-bar__count'.freeze
  STORYGRID = '.grid__container'.freeze
  GRIDITEM = '.pb-grid__item'.freeze
  QUICKVIEW = "Quick View".freeze
  QUICKMORE = ".pb-dropdown .pb-dropdown--open .pb-book-card__dropdown".freeze
  DROPDOWN = '.pb-menu-item__label'.freeze
  IFRAME = '.pb-book-reader__frame'.freeze
  SEARCHBOX = '.pb-text-field__box'.freeze
  SEARCHFILED = 'input.pb-text-field__input'.freeze
  ALLBOOKS = '.pb-all-books'.freeze
  QUICKVIEWTITLE = '.pb-quick-view-modal__title'.freeze
  QUICKPOPUPMAIN = '.pb-modal__bounds'.freeze
  STATVALUE = '.pb-stat__value'.freeze

  def read_page?
    parse_current_url.path == URLPATH
  end

  def get_filters
    find(FILTERS).all('li').map(&:text)
  end

  def add_filter(filter_name, value, skip_search = false)
    select_filter(filter_name)
    search_for(value) unless skip_search && get_filter_options.include?(value)
    within find(FILTERS) do
      select_checkbox(value)
    end
    select_filter(filter_name)
  end

  def sort_by(sort_using)
    find(SORTBY).select sort_using
  end

  def get_sort_by_options
    find(SORTBY).all('option').map(&:text)
  end

  def filters_applied
    find(FILTERBARSTATUS).all(SELECTEDFILTERS).map(&:text)
  end

  def load_more
    click_link LOADMORE
  end

  def more_quick_view(story_title, action_name, skip_popup_check = true)
    return_data = popup_return_data
    add_quick_view(story_title)
    within story_card(story_title).find(:xpath, '../..') do
      all('a')[2].click
      page.execute_script "window.scrollBy(0,100)"
      find(DROPDOWN, text: action_name, visible: false, wait: WAIT5).click
      sleep WAIT5
    end
    return_data.merge!(popup_content) if skip_popup_check && popup?
    return_data
  end

  def quick_view_actions(story_title)
    return_data = []
    reload_page
    within story_card(story_title) do
      add_quick_view(story_title)
    end
    within story_card(story_title).find(:xpath, '../..') do
      all('a')[2].click
      page.execute_script "window.scrollBy(0,100)"
      return_data = all(DROPDOWN).map(&:text)
    end
    reload_page
    return_data
  end

  def click_quick_view(story_title)
    within story_card(story_title) do
      add_quick_view(story_title)
    end
    within story_card(story_title).find(:xpath, '../..') do
      all('a')[1].click
    end
  end

  def quick_view_popup_details
    return {} unless has_css? QUICKVIEWTITLE
    title = find(QUICKVIEWTITLE).text
    likes, views = all(STATVALUE).map(&:text)
    views = 0 if views.kind_of? NilClass
    {popup: 'QuickView', title: title, likes: likes, views: views}
  end

  def all_stories
    has_css? STORYCARDLINK
    all(STORYCARDLINK).map{|a_ele| react_text(a_ele) }
  end

  def story_details(title)
    details = {}
    story_card = find(TITLE, text: title, exact: true, wait: WAIT5).find(:xpath, '../..')
    within story_card do 
      details[:language] = find(LANGUAGE).text
      details[:level] = find(LEVEL).text
      details[:translated], details[:illustrated] = all(TRANSLATEDILLUSTRATED).map(&:text)
      details[:views] = find(VIEWS).text.to_i rescue 0
      details[:recommended] = has_css? RECOMMENDATION
      details[:title] = title
    end
    details
  end

  def read_story(title)
    story_card(title).find(:xpath, '../../..').click
  end

  def stories_count
    find(STORYCOUNT).text.to_i
  end

  def select_filter(filter_name)
    within find(FILTERS) do
      click_link filter_name
    end
  end

  def search_box?
    has_css? SEARCHBOX
  end

  def search_for(filter)
    find(SEARCHFILED).set filter
  end

  def get_filter_options(filter_name=nil)
    select_filter(filter_name) if filter_name.kind_of? String
    return_array = []
    has_css? CHECKBOX
    page.find(FILTERS).all(CHECKBOX).each do |ele|
      return_array << (ele.text rescue '')
    end
    return_array
  end

  def translation_missing?(options)
    !options.select{|option| option.include? "translation missing"}.empty?
  end

  def get_first_story_title
    get_first_story_ele.find(TITLE).text
  end

  def quick_view_popup?
    popup?
  end

  def login_popup?
    flag_hash = popup_content
    return flag_hash unless flag_hash
    flag_hash[:title] == 'Log In'
  end

  def quick_view_footer(action_name)
    within find(QUICKPOPUPMAIN) do
      click_link action_name
    end
  end

  private

  def select_checkbox(value)
    all(CHECKBOX).find{|ele|  ele.text.to_s == value.to_s}.click
  end

  def add_quick_view(title)
    title_card(title).hover
  end

  def get_first_story_ele
    ele = []
    has_css? GRIDITEM
    sleep 2
    within ALLBOOKS do
      ele = all(GRIDITEM).first
    end
    ele
  end

  def story_card(story_title)
    find(TITLE, text: story_title, exact: true, wait: WAIT5).find(:xpath, '../..')
  end

  def title_card(story_title)
    find(TITLE, text: story_title, exact: true, wait: WAIT5)
  end

end
