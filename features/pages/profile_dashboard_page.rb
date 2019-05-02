class ProfileDashBoard < UserDashBoard

  GRIDITEM = '.pb-grid__item'.freeze
  GRIDCONTAINER = '.grid__container'.freeze
  CARDTITLE = '.pb-book-card__title'.freeze
  IMAGECARDTITLE = '.pb-image-card__title'.freeze
  ACTIVETAB = '.pb-tabs__tab-link--active'.freeze
  PROFILETITLE = '.pb-profile__title'.freeze
  PROFILEDESCRP = '.pb-profile__description'.freeze
  SHRINKER = '.pb-shrinker'.freeze
  TABSTABS = '.pb-tabs__tabs'.freeze
  READINGLISTCARD = '.pb-reading-list-card'.freeze
  READINGLISTBOOKS = '.pb-reading-list__books'.freeze

  MYBOOKSHELF = "My Bookshelf".freeze

  # DEFAULTHASH = {count: 0, files:[] }.freeze

  # class << self; attr_accessor :properties end

  # self.properties = {images: DEFAULTHASH, illustrations: DEFAULTHASH, translations: DEFAULTHASH,
  #                   relevels: DEFAULTHASH, my_bookshelf: DEFAULTHASH, media_mentions: DEFAULTHASH }

  # def self.[](prop_name)
  # self.properties[prop_name]
  # end

  # def self.[]=(prop_name, count_incr)
  # ProfilePage[prop_name][:count] += count_incr
  # end

  # def add_files_of(key_name, file_name)
  #   ProfilePage[key_name][:files].push(file_name)
  # end

  # def get_files_of(key_name, file_name)
  #   ProfilePage[key_name][:files]
  # end

  # def get_count_of(key_name)
  # ProfilePage[key_name][:count]
  # end

  def tabs_available
    find(TABSTABS).all('a').map(&:text)
  end

  def user_details
  {
    user_name: find(PROFILETITLE).text,
    description: (find("#{PROFILEDESCRP} #{SHRINKER}").text rescue ''),
    organization: organization_details,
    tabs: tabs_available,
    url: current_url
  }
  end

  def organization_details
    begin
      link = find(PROFILEDESCRP).find('a')
      {webele: link, orgname: link.text }
    rescue
      {}
    end
  end

  def get_tab_count(tab_name)
    tab_name = tab_name.downcase
    tabs_available.find{|tab| tab.downcase.include? tab_name}.scan(/\d+/).first.to_i || 0
  end

  def get_active_tab
    find(ACTIVETAB).text.scan(/\w+/).first.downcase
  end

  def select_tab(tab_name)
    return if tab_name == get_active_tab
    tab_name = tab_name.downcase
    click_link tabs_available.find{|full_tab_name| full_tab_name.downcase.include? tab_name}
  end

  def all_illustrations_detail
    container_grid {
      all(GRIDITEM).map do |grid_item|
        {image_name: grid_item.find(IMAGECARDTITLE).text }
      end
    }
  end

  def get_bookshelf_stories
    select_tab MYBOOKSHELF
    find(READINGLISTCARD).click
    find(READINGLISTBOOKS).all(CARDTITLE).map(&:text)
  end

  def all_stories_detail
    container_grid {
      all(GRIDITEM).map do |grid_item|
        {story_name: grid_item.find(CARDTITLE).text }
      end
    }
  end

  def container_grid
    main_ele = find('.pb-tabs').find(GRIDCONTAINER) rescue 0
    return 0 unless Capybara::Node::Element === main_ele
    within main_ele do
      yield
    end
  end

end
