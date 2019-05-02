class UserDashBoard < BasePage
  OPTIONNOTAVAILABLE = "Option not available, Available are:: %s".freeze

  NAVPRIM = '.pb-site-header__nav-primary'.freeze
  DROPDOWNTOGGLE = '.pb-dropdown__toggle'.freeze
  DROPDOWNCONTENTS = '.pb-dropdown__contents'.freeze

  LOGOUT = 'Logout'.freeze

  def dashboards_available
    begin
      within find(NAVPRIM) do
        raise SWErrors::LoginRequiredError unless has_css? DROPDOWNTOGGLE
        find(DROPDOWNTOGGLE).click
      end
      find(DROPDOWNCONTENTS).all('li').map(&:text)
    rescue SWErrors::LoginRequiredError => login_error
      login_error.print_details
    end
  end

  def select_dashboard(dashboard_name)
    close_pop_up_notification
    dashboards_avail = dashboards_available
    raise ( OPTIONNOTAVAILABLE % (dashboards_avail * ' ,') ) unless dashboards_avail.include? dashboard_name
    within find(NAVPRIM) do
      has_text? dashboard_name
      click_link dashboard_name 
    end
  end

  def logout_tool
    within find(NAVPRIM) do
      click_link LOGOUT  
    end
  end

end