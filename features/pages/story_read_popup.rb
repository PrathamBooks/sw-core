class StoryReadPopup < BasePage

  RATINGSERROR = 'Please select the Available smiley ratings : %s'

  IFRAME = '.pb-book-reader__frame'.freeze
  POPUP = '.pb-modal__bounds'.freeze
  NEXT = 'Next'.freeze
  PREVIOUS = 'Previous'.freeze
  CLOSE = 'Close'.freeze
  SIMLEYRATING = '.pb-three-point-rating'.freeze
  SRATING = '.pb-lottie-animation'.freeze
  SUBMIT = 'Submit'.freeze
  AVAILABLERATINGS = ["okay", "like", "love"].freeze
  READERPOPUP = '.pb-book-reader__wrapper'.freeze
  ANOTHERCLOSE = 'a.pb-modal__close'.freeze
  NEXTREAD =".pb-center-mode-carousal".freeze
  STORYNAME = 'Mockstory'.freeze
  NEXTREADCLICK ='.pb-center-mode-carousal__cta-wrapper'.freeze
  STORYTITLE = '.pb-book-card__title'.freeze
  NEXTSTORIES ='.pb-center-mode-carousal__container'.freeze
  NEXTREADSTORYNAMEERROR = 'Please select the Available next read suggestion stories : %s'

  def story_reader_popup?
    has_css? READERPOPUP
  end

  def next_page
    within_popup { click_link NEXT }
  end

  def previous_page
    within_popup { click_link PREVIOUS }
  end

  def next_page?
    within_popup { has_link? NEXT } && !smiley_rating?
  end

  def previous_page?
    within_popup { has_link? PREVIOUS }
  end

  def close_popup
    within_popup do
      click_link CLOSE rescue find(ANOTHERCLOSE).click
    end
  end

  def complete_story_with(smile_rating = false,next_read_story = false)
    story_reader_popup?
    sleep WAIT5
    return_hash = read_story
    sleep WAIT5
    click_link 'Agree' rescue ""
    smile_rating ? simley_rating(smile_rating) : click_link(NEXT)
    if next_read_story
      return nextread_suggestions(next_read_story) 
    end
    close_popup
    return_hash
  end

  def smiley_rating?
    sleep 5
    has_css? SIMLEYRATING || has_link?("Report")
  end

  def next_read?
    sleep WAIT5
    has_css? NEXTREAD || has_link?("Read Story")
  end

  def next_stories
    stories = []
    within NEXTSTORIES do
      stories = all(STORYTITLE).map(&:text)
    end
    return stories
  end

  def next_click 
     within  NEXTREADCLICK do
       click_link "Read Story"
     end
  end

  def nextread_suggestions(story_name)
    next_index = next_stories.index(story_name)
    raise NEXTREADSTORYNAMEERROR % next_stories.join(", ") if next_index == nil
    ele=0
    while ele <= next_stories.count do
      find('.slick-arrow.slick-next').click
      sleep WAIT5
      param = find('.slick-current').find(STORYTITLE).text  
      if param == story_name
        next_click
        sleep WAIT5
        break
      end
      ele = ele + 1
    end
  end

  def simley_rating(rating)
    rating_index = AVAILABLERATINGS.index(rating)
    raise RATINGSERROR % AVAILABLERATINGS.join(", ") if rating_index == nil
    within_popup do
      find(SIMLEYRATING).all(SRATING)[rating_index].find('div').click
      click_link SUBMIT
    end
  end

  private

  def read_story
    return_hash = {}
    return_hash[:pages] = 0
    loop do
      break if smiley_rating?
      next_page
      sleep WAIT1
      return_hash[:pages] += 1
    end
    return_hash
  end

  def within_popup
    within POPUP do
      yield
    end
  end

  def with_iframe
    within_frame IFRAME do
      yield
    end
  end
end
