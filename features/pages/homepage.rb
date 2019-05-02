class HomePage < BasePage
  AVAILABLE_ACTIONS = ["Editor’s Picks", 'Most Read', 'New Arrivals'].freeze

  def home_page_details
    return_hash = {}
    return_hash.merge!(blogs)
    return_hash.merge!(stories_lang_reads)
    return_hash.merge!(login_user)
    return_hash.merge!(all_story_details)
    return_hash
  end

  def blogs
    blogs = {}
    within find('.pb-blog-posts') do
      blogs[:blogs_count] = 0
      blogs[:blog_details] = Array.new
      all('.pb-grid__item').each do|web_ele|
        blogs[:blog_details] << {
                                  title: web_ele.find('.pb-article-blurb__title a').text,
                                  summary: web_ele.find('.pb-article-blurb__summary').text
                                }
        blogs[:blogs_count] += 1
      end
    end
    blogs
  end

  def stories_lang_reads
    return_hash ={}
    within find('.pb-stats-bar') do
      all('.pb-columnizer__column').each do |web_ele|
        return_hash[web_ele.find('.pb-stat__label').text.downcase] =  web_ele.find('.pb-stat__value').text.to_i
      end
    end
    return_hash
  end



  def login_user
    {
      logged_in: logged_in?,
      username: user_details
    }
  end

  def user_details
    find('.pb-site-nav-link__title').text rescue 'Guest'
  end

  def logged_in?
    !(find('.pb-site-nav-link__title').text == 'Log In')
  end

  def all_category_details
    return_array = []
    within find('.pb-category-container') do
      all('.pb-grid__item').each do |category|
        title = category.find('.pb-category-card__title')
        webele = category.find('.pb-category-card__image a')
        return_array << {title: title, web_element: webele}
      end
    end
    return_array
  end

  def select_category(category_name)
    category_details = all_category_details
    category = category_details.find{|category| category[:title].downcase == category.downcase}
    if NilClass === category
      raise "No Category found! Avaliable Categories" %category_details.map{|category| category[:title]}.join(', ')
    end
    category[:web_element].click
  end

  def all_story_details
    return_hash = {}
    return_hash[:stories] = []
    return_hash[:total_stories] = 0
    within find('.pb-tabs') do
      return_hash[:active_tab] = find('a.pb-tabs__tab-link--active').text
      within find('.pb-tab--active') do
        all('.pb-grid__item').each do |story_card_ele|
          lang = story_card_ele.find('.pb-book-card__meta-wrapper .pb-book-card__language').text
          level = story_card_ele.find('.pb-book-card__level').text
          title = story_card_ele.find('.pb-book-card__meta .pb-book-card__title').text
          authors = all('.pb-book-card__meta .pb-book-card__names').map(&:text)
          recommended = story_card_ele.has_css? '.pb-book-card__recommendation'
          views = story_card_ele.find('.pb-book-card__footer .pb-stat__value').text.to_i
          return_hash[:stories] << {title: title, language: lang, level: level, authors: authors,
                                    recommended: recommended, views: views}
          return_hash[:total_stories] += 1
        end
      end
    end
    return_hash
  end

  def view_all(view: "Editor’s Picks")
    view = AVAILABLE_ACTIONS.find{|action| action.downcase == view.downcase}
    if NilClass === view
      raise "View all Not found! Avaliable View all are %s" % AVAILABLE_ACTIONS.join(', ')
    end
    method_view = view.gsub("'","").downcase.gsub(" ","_")
    send(method_view)
    sleep WAIT2



    
    find('.pb-tab--active').click_link 
  end

  def editors_pick
    click_link "Editor’s Picks"
  end

  def most_read
    click_link 'Most Read'
  end

  def new_arrivals
    click_link 'New Arrivals'
  end


end





