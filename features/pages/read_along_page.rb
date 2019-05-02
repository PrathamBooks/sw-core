require_relative 'read_page'

class ReadAlongPage < ReadPage

  HEADER            = '.pb-page-header__wrapper'.freeze
  HEADERTITLE       = 'h1.pb-page-header__title'.freeze
  HOVERCONTROLS     = '.pb-book-card__hover-controls'.freeze
  READALONG         = 'Readalong'.freeze
  AUDIOSPATH        = '/audios'.freeze
  ISAUDIO           = 'isAudio=true'.freeze

  def read_along_page?
    ( (find(HEADER).has_text? READALONG) && (active_tab == READALONG) &&
    (parse_current_url.path == AUDIOSPATH) && (parse_current_url.query.include? ISAUDIO) )
  end

  def get_filters
    super
  end

  def add_filter(filter_name, value)
    super(filter_name, value)
  end

  def filters_applied
    super
  end

  def read_along_story?(story_name)
    story_name = get_first_story_title if story_name.kind_of? NilClass
    hover_actions_parent_ele = (find(ReadPage::STORYCARDLINK, text: /#{story_name}/i, visible: false).find(:xpath, '../..').find(HOVERCONTROLS, visible: false) rescue nil)
    return false if hover_actions_parent_ele.kind_of? NilClass
    svg_class = hover_actions_parent_ele.all('svg', visible: false).map{|ele| ele[:class]}
    svg_class.select{|ele| ele.include? READALONG.downcase}.any?
  end

  def read_along_header?
    has_text? READALONG
    find(HEADER).find(HEADERTITLE).text == READALONG
  end

  def get_first_story_title
    super
  end

  def story_details(title)
    basic_details = super(title)
    within find(TITLE, text: title, exact: true, wait: WAIT5).find(:xpath, '../..') do |parent_ele|
      svg_class = parent_ele.find(HOVERCONTROLS, visible: false).all('svg', visible: false).map{ |svg_ele| 
                    svg_ele[:class]
                  }
      hover_actions = ["read", "readalong"].map{ |action|
                        [action.to_sym, svg_class.any? {|_class| _class.include? action}]
                      }.to_h
    end
    basic_details.merge!(hover_actions: hover_actions)
  end

  def select_first_story(title)
    find("a", :text => /#{title}/i).click
  end

end