class LoginPage < BasePage

  LOGINFORM = '#loginForm'.freeze
  URLPATH = '/users/sign_in'.freeze
  ALERT = '.alert'.freeze
  USEREMAIL = '#user_email'.freeze
  USERPASSWORD = "#user_password".freeze
  LOGIN = 'Log In'.freeze

  def login_using(opts)
    close_popup
    click_login unless login_page?
    sleep WAIT2
    within LOGINFORM do
      sleep WAIT2
      enter_email(opts['Email'])
      enter_password(opts['Password'])
      click_button 'Log in'
    end
    close_popup
    click_link 'Agree' rescue p "No Agree button"
  end

  def click_login
    page.find('.pb-site-header__nav-primary').click_link LOGIN
  end

  def login_page?
    URI.parse(current_page_url).path == URLPATH
  end

  def login_errors?
    page.has_css? ALERT
  end

  def error_message
    find(ALERT).text
  end

  def has_field?(ele)
    field = instance_eval("LoginPage::USER#{ele}")
    has_css? field
  end

  private

  def enter_email(email)
    find(USEREMAIL).set email
  end

  def enter_password(password)
    find(USERPASSWORD).set password
  end
end
