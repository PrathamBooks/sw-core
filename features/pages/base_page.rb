class BasePage
  include Capybara::DSL
  include SWExtendedCapybaraFinders
  extend PageHelpers

  WAIT1 = 1.freeze
  WAIT2 = 2.freeze
  WAIT3 = 3.freeze
  WAIT4 = 4.freeze
  WAIT5 = 5.freeze
  WAIT15 = 15.freeze

  TIMEOUT = "Timeout! Page taking too much time to load".freeze

  HEADERCLASS = ".pb-site-header__nav-secondary".freeze
  MOALCONTAINER = '.pb-modal__container'.freeze
  POPUP = ".pb-modal__bounds".freeze
  POPUPFOOTER = ".pb-modal__footer".freeze
  FOOTERACTIONSABSENT = "No Footer Actions present".freeze
  POPUPTITLE = '.pb-quick-view-modal__title'.freeze
  CLOSEPOPUP = 'a.pb-modal__close'.freeze
  MODALCONTENT = '.modal-content'.freeze
  MODALTITLE = '.modal-title'.freeze
  MODALBODY = '.modal-body'.freeze
  MODALFOOTER = '.modal-footer'.freeze
  LOGININLINEMSG = 'Log In'.freeze
  DROPDOWNCONTENTS = '.pb-dropdown__contents'.freeze
  DROPDOWNCONTENT = '.pb-dropdown__content'.freeze
  MODELCONTENT = '.pb-modal__content'.freeze
  MODALHEADER = '.pb-modal__header'.freeze
  CANCEL = 'Cancel'.freeze

  def wait_for_loader(timeout = 10)
    Timeout.timeout(timeout) do
      break unless has_css? '.pb-loader'
      sleep 1
    end
  end

  def current_page_url
    page.current_url
  end

  def force_url(path)
    visit "https://#{parse_current_url.host}/#{path}"
  end

  def parse_current_url
    URI.parse(current_page_url)
  end

  def flash_message
    return {type: 'notice',message: find('#flash_notice').text } if has_css? '#flash_notice'
  end
  
  def navigate_to(page)
    find(HEADERCLASS).click_link page
  end
  
  def close_pop_up_notification
    within find('.pb-slim-notification-container') do
      find('.pb-slim-notification__close').click if has_css?('.pb-slim-notification__close')
    end if slim_pop_up_notification?
  end

  def slim_pop_up_notification_text
    return within find('.pb-slim-notification-container') do
      find('p.pb-slim-notification__content').text
    end if slim_pop_up_notification?
    ""
  end

  def slim_pop_up_notification?
    has_css? ('.pb-slim-notification-container')
  end

  def popup?
    page.has_css? POPUP
  end

  def popup
    within find(POPUP) do
      yield
    end
  end

  def complete_file_path(file_name)
    root_dir = (defined? ::Rails) ? ::Rails.root.to_s : Dir.pwd
    root_dir + "/features/testfiles/#{file_name}"
  end

  def validation_error_details
    return_hash = {popup: false, type: :validation}
    return return_hash unless has_css?('.pb-notification--danger')
    within find('.pb-notification--danger') do
      return_hash[:title] = find('.pb-notification__title').text
      return_hash[:message] = find('.pb-notification__content').text
      return_hash[:popup] = true
      find('a').click
    end
    return_hash
  end

  def get_popupfooter_actions
    find(POPUP).find(POPUPFOOTER).all('a').map{ |action| {action.text => action} }
  end

  def inline_login?
    return false unless page.has_css? (DROPDOWNCONTENTS)
    find(DROPDOWNCONTENTS).all('a').first.text.start_with? LOGININLINEMSG
  end

  def inline_login
    return false unless inline_login?
    login, signup = find(DROPDOWNCONTENTS).all('a')
    {login: login, signup: signup}
  end

  def click_popupfooter_action(action_name="Log In")
    actions = get_popupfooter_actions
    raise FOOTERACTIONSABSENT if action.empty?
    actions.select{|action| action.keys.first.downcase == action_name.downcase}.values.first.click
  end

  def popup_content
    return false unless popup?
    return_data ={}
    popup {
      return_data[:title] = find(POPUPTITLE).text
      return_data[:body] = find('p').text
      return_data[:popup] = true
    }
    return_data
  end

  def close_popup
    popup { 
      find(CLOSEPOPUP).click
      } if popup?
  end

  def popup_return_data
    {errors: false, popup: false}
  end

  def return_error_hash
    {errors: false, message: ''}
  end

  def reload_page
    evaluate_script 'window.location.reload()'
  end

  def active_tab
    (find('.pb-site-header__nav-secondary .pb-site-nav-link--active').text rescue "")
  end

  def react_text(node_ele)
    node_ele['innerHTML'].split('-->').last.split('<!--').first
  end
end
