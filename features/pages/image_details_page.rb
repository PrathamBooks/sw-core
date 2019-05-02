class ImageDetailsPage < BasePage

  ILLUSTRATIONSPATH = '/illustrations/'.freeze
  IMAGES = 'Images'.freeze
  HOMEIMAGES = 'HomeImages'.freeze
  REPORT = 'Report'.freeze
  CREATESTORY = 'Create Story'.freeze
  REPORTIMAGE = 'Report this Image'.freeze
  DEFAULTREPORT = 'This is a copyrighted image that does not belong to the person attributed.'.freeze
  REPORTED = 'Reported'.freeze
  PUBLISHER = '.pb-publisher'.freeze
  PUBLISHEDBY = 'Published By'.freeze
  LIKE = 'Like'.freeze
  SUCCESSFUL = 'successful'.freeze
  LOGINREQ = 'LogIn Required'.freeze
  DEFAULTTEXT = "Default Text".freeze
  ALREADYREPORTED = 'Already reported'.freeze
  ALREADYLIKED = 'Already liked'.freeze

  ILLUSHEADER = '.pb-illustration__header'.freeze
  ILLUSSTATUS = '.pb-illustration__stats'.freeze
  BREADDRUMB = '.pb-breadrumb'.freeze
  STATLABEL = '.pb-stat__label'.freeze
  STATVALUE = '.pb-stat__value'.freeze
  EMPTYHEART = '.pb-svg-icon--type-heart-outline'.freeze
  ILLUSTITLE = '.pb-illustration__title'.freeze
  ILLUSDESC = '.pb-illustration__description'.freeze
  TXTAREATEXTFIELDINPUT = 'textarea.pb-text-field__input'.freeze

  def image_details_page?
    (parse_current_url.path.start_with? ILLUSTRATIONSPATH) &&
    (active_tab == IMAGES) &&
    (find(BREADDRUMB).text == HOMEIMAGES)
  end

  def can_like?
    within find(ILLUSSTATUS) do
      (has_text? LIKE ) || (has_css? EMPTYHEART)
    end
  end

  def like_count
    (find("#{ILLUSSTATUS} span#{STATVALUE}").text.to_i rescue 0)
  end

  def view_count
    find(STATLABEL, text: /views/i).find(:xpath, '..').find(STATVALUE).text.to_i
  end

  def reported?
    page.has_text? REPORTED
  end

  def report(with: DEFAULTREPORT, text: DEFAULTTEXT)
    status, error, message = 'not ok', true, ALREADYREPORTED
    return {status: status, error: error, message: message} if reported?
    click_link REPORT
    message = LOGINREQ
    return {error: error, inline_login: inline_login?, message: message} unless popup?
    return_data = report_popup(with, text)
    find(BasePage::POPUPFOOTER).click_link REPORT
    status, error, message = 'ok', false, SUCCESSFUL
    return_data.merge({reported: reported?, error: error, status: status, message: message})
  end

  def like_image
    status, error, message = 'not ok', true, ALREADYLIKED
    return {status: status, error: error, message: message} unless can_like?
    inital_count = like_count
    handle_like_image
    sleep BasePage::WAIT2
    updated_like = like_count
    if updated_like == inital_count
      (message = LOGINREQ) if inline_login?
    else
      status, error, message = 'ok', false, SUCCESSFUL
    end
    {error: error, status: status, message: message}
  end

  def create_story
    has_text? CREATESTORY
    click_link CREATESTORY
    sleep BasePage::WAIT15
  end

  def image_title
    find(ILLUSTITLE).text
  end

  def image_details
    {
      title: image_title,
      author: image_author,
      views: view_count,
      like_count: like_count,
      liked: !can_like?,
      reported: reported?,
      published_by: published_by,
      story_used: story_used
    }
  end

  def share(to: 'facebook')
    li_ele = find('a', text: 'Share').find(:xpath, '../../..')
    within li_ele do
      click_link 'Share'
      find(BasePage::DROPDOWNCONTENTS).find('a', text: /#{to}/i).click
    end
  end

  def download_options
    return_data = []
    li_ele = find('a', text: 'Download').find(:xpath, '../../..')
    within li_ele do
      click_link 'Download'
      return_data = find(BasePage::DROPDOWNCONTENTS).all('a').map(&:text)
    end
    return_data
  end

private

  def report_popup(report_with, text)
    return {report_popup: false} unless report_popup?
    find(BasePage::MODELCONTENT).find('label', text: report_with).click
    {reported_with: report_with, text_area: report_textarea(text)}
  end

  def report_popup?
    find(BasePage::MODALHEADER).text == REPORTIMAGE
  end

  def report_textarea(text)
    return false unless has_css?(TXTAREATEXTFIELDINPUT)
    find(TXTAREATEXTFIELDINPUT).set text
    text
  end

  def image_author
    find(ILLUSHEADER).all('a').first.text
  end

  def published_by
    return "" unless has_css?(PUBLISHER)
    data = ''
    within find(PUBLISHER) do
      data = all('a').map(&:text).last
      if data.is_a? NilClass
        _data = all('p').first.text.gsub(PUBLISHEDBY,"").strip
        data = _data unless _data.empty?
      end
    end
    data
  end

  def story_used
    (find(ILLUSDESC).find('a').text rescue "")
  end

  def handle_like_image
    return find(EMPTYHEART).click if has_css? EMPTYHEART
    click_link LIKE
  end

end
