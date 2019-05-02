require_relative 'user_dash_board.rb'

class DashBoard < UserDashBoard

  URLPATH = '/v0/profile'.freeze
  EDIT = 'edit'.freeze
  DELETE = 'delete'.freeze
  ACTIONS = 'ACTIONS'.freeze
  SUBMIT = 'Submit'.freeze
  CHANGEPASSWORD = 'Change Password'.freeze
  SAVENEWPASSWORD = "Save new password".freeze
  LABEL = 'label'.freeze
  SPAN = 'span'.freeze
  FIRSTNAME = 'First Name'.freeze
  LASTNAME = 'Last Name'.freeze
  PROFILEDESC = 'Profile description'.freeze
  EMAILFIELD = '.email-mob'.freeze
  LANGPREFERENCES = 'Language Preferences'.freeze
  READINGLEVELS = 'Reading Levels'.freeze
  WEBSITE = 'Website'.freeze

  ULTABS = 'ul#myTab'.freeze
  CONFIRMDIALOG = '#confirmation_dialog'.freeze
  LIACTIVESPAN = 'li.active span'.freeze
  PASSWORDMODAL = '#passwordModal'.freeze
  USERCURRENTPASSWORD = '#user_current_password'.freeze
  USERPASSWORD = '#user_password'.freeze
  USERPASSWORDCONFRM = '#user_password_confirmation'.freeze
  USERDBROWSPAN = 'tr.user_dashboard_row span'.freeze
  TBROWDETAILS = '.table-row-details'.freeze
  PROFILEPAGE = '#profile-page'.freeze
  PAGINATION_A = 'nav.pagination a'.freeze
  PAGINATION_PAGE = 'nav.pagination .page'.freeze
  TBHEADINGROW = '.table-heading-row'.freeze
  BECOMEORGUSER = 'Become an Organisational User'.freeze
  

  def select_dashboard
    super('Dashboard')
  end

  def dashboard_page?
    URI(current_page_url).path.start_with? URLPATH
  end

  def available_dashboard_tabs
    find(ULTABS).all(SPAN).map(&:text)
  end

  def goto_dashboard_tab(tab_name)
    tab_name = tab_name.humanize
    return 'ok' if active_dashboard == tab_name
    available_dashboard_tabs.include? tab_name
    click_link tab_name
  end

  def active_dashboard
    find("#{ULTABS} #{LIACTIVESPAN}").text
  end

  def all_story_titles
    find(TBROWDETAILS).all('tr').map do |td_ele|
      td_ele.all('td').first.text
    end
  end

  def all_illustration_titles
    find(TBROWDETAILS).all('tr').map do |td_ele|
      td_ele.all('td')[1].text
    end
  end

  def my_details_data
    {
      first_name: sw_text_field(field_name: FIRSTNAME),
      last_name: sw_text_field(field_name: LASTNAME),
      description: sw_text_area(field_name: PROFILEDESC),
      email: find(EMAILFIELD).all('label').last.text,
      website: sw_text_field(field_name: WEBSITE),
      reading_preferences: {
        language_preferences: sw_multi_select(field_name: LANGPREFERENCES),
        reading_levels: sw_multi_select(field_name: READINGLEVELS)
        },
      updates_newsletter: sw_check_box(field_name: 'I want to receive updates and newsletter.'),
    }
  end

  def my_details
    goto_dashboard_tab('my_details')
  end

  def update_my_details(options={})
    my_details if active_dashboard != 'My Details'
    all_fields = find('.prof_form').all('label').map(&:text)
    not_filled_fields = []
    options.each do |field_name, value|
      not_filled_fields << field_name and next unless all_fields.include? field_name
      type = get_type_of_sw(field_name)
      send(type, field_name: field_name, field_value: value, method: :set) rescue not_filled_fields << field_name
    end
    p 'Following fields are not filled %s' % [(not_filled_fields * (", ") )]
    execute_script "window.scrollBy(0,10000)"
    submit_my_details
  end

  def become_an_organisational_user
    my_details if active_dashboard != 'My Details'
    execute_script "window.scrollBy(0,10000)"
    page.find("a", text: BECOMEORGUSER).click
  end

SEPERATE_FLOW  = ["NUMBER OF CLASSROOMS", "NUMBER OF CHILDREN IMPACTED (APPROXIMATELY)"]
  def fill_org_form(options={})
    inputs = find('form#new_organization').all('label').map(&:text)
    inputs.each do |label_name|
      value = options[label_name] || default_become_org_details[label_name]
      next  if SEPERATE_FLOW.include? label_name
      type = get_type_of_sw(label_name)
      send(type, field_name: label_name, field_value: value, method: :set) #rescue not_filled_fields << label_name
    end
    find("#organization_signup_model").find("input[value='Submit']").click
    sleep 10
  end
# send("fill_#{label_name.gsub(' ','_').split('(').first.downcase}", value)
  def fill_number_of_classrooms(value)
    sw_text_field(field_name: SEPERATE_FLOW.first, field_value: value.to_i, method: :set)
  end

  def fill_number_of_children_impacted(value)
    sw_text_field(field_name: SEPERATE_FLOW.last, field_value: value.to_i, method: :set)
  end


  def default_become_org_details
    {
      "COUNTRY NAME" => 'Cuba',
      "NAME OF THE ORGANISATION" => 'PrathamBooks',
      "NUMBER OF CLASSROOMS" =>  5,
      "NUMBER OF CHILDREN IMPACTED" => 5,
      "WHICH STATES/CITIES ARE YOU WORKING IN?" => 5
    }
  end

  ['my_published_stories', 'published_stories_under_edit', 'my_illustrations', 'my_drafts', 'my_submitted_stories'].each do |tab_name|
    define_method tab_name.to_sym do
      goto_dashboard_tab(tab_name)
    end
  end

  # def my_published_stories
  #   goto_dashboard_tab("my_published_stories")
  # end

  # def published_stories_under_edit
  #   goto_dashboard_tab('published_stories_under_edit')
  # end

  # def my_illustrations
  #   goto_dashboard_tab('my_illustrations')
  # end

  # def my_drafts
  #   goto_dashboard_tab('my_drafts')
  # end

  def deactivated_stories
    goto_dashboard_tab('de-activated_stories')
  end

  # def my_submitted_stories
  #   goto_dashboard_tab('my_submitted_stories')
  # end


  ['my_published_stories?', 'published_stories_under_edit?', 'my_illustrations?', 'my_drafts?', 'my_submitted_stories?'].each do |tab_name|
    define_method tab_name.to_sym do |story_name|
      send(tab_name[0..-2]) if active_dashboard != tab_name.humanize
      all_story_illustrations.include? story_name      
    end
  end

  # def my_published_stories?(story_name)
  #   my_published_stories if active_dashboard != 'My Published Stories'
  #   all_story_illustrations.include? story_name
  # end

  # def published_stories_under_edit?(story_name)
  #   published_under_edit if active_dashboard != 'Published Stories Under Edit'
  #   all_story_illustrations.include? story_name
  # end

  # def my_illustrations?(illustration_name)
  #   my_illustrations if active_dashboard != 'My Illustrations'
  #   all_story_illustrations.include? illustration_name
  # end

  # def my_drafts?(story_name)
  #   my_drafts if active_dashboard != 'My Drafts'
  #   all_story_illustrations.include? story_name
  # end

  def deactivated_stories?(story_name)
    deactivated_stories if active_dashboard != 'De-activated Stories'
    all_story_illustrations.include? story_name
  end
  
  # def my_submitted_stories?(story_name)
  #   my_submitted_stories if active_dashboard != 'My Submitted Stories'
  #   all_story_illustrations.include? story_name
  # end

  def all_story_details(all_pages = false, page_number = 1)
    return_hash = {}
    no_of_pages = 1
    navigate_to_page(page_number) if page_number != 1
    no_of_pages = total_pagination_pages if all_pages
    headings = find(TBHEADINGROW).all('th').map(&:text)
    return_hash[:headings] = headings
    return_hash[:total_count] = 0
    within find(PROFILEPAGE) do
      total_count = 0
      [*(1..no_of_pages)].each do |page_num|
        navigate_to_page(page_num)
        row_details = find(TBROWDETAILS).all('tr').map{|web_ele| web_ele.all('td').map(&:text)}
        count = row_details.count
        return_hash[page_num] = {details: row_details, count: count}
        return_hash[:total_count] += count
      end
    end
    return_hash
  end

  def navigate_to_page(page_num)
    page_num = page_num.to_i
    find(PAGINATION_A,text: page_num).click
  end

  def total_pagination_pages
    all(PAGINATION_PAGE).count
  end

  def click_story_with_name(story_name)
    click_link story_name
  end

  def select_action_for(story_name:, action_name:)
    story_web_ele = all(USERDBROWSPAN, text: story_name).first
    action_ele =  story_web_ele.find(:xpath, '../../..').all('td')
    action_ele = action_ele.find do |web_ele|
      next if NilClass === web_ele[:class]
      (web_ele[:class].include? action_name) || (web_ele[:class].include? 'edit')
    end
    link_count = action_ele.all('a').count
    link = link_count < 2 ? action_ele.find('a') : action_ele.all('a').find{|ele| ele[:class].include? action_name}
    link.click
  end

  def open_story_new_tab(story_name:)
    find('table tbody').all('tr').find{ |ele| ele.text.include? story_name }.all('a').first.click
  end

  def confirmation_pop_up(action = true)
    return {confirmation_popup: false} if !has_css? CONFIRMDIALOG
    return_hash = {confirmation_popup: true}
    within find(BasePage::MODALCONTENT) do
      return_hash[:title] = find(BasePage::MODALTITLE).text
      return_hash[:message] = find(BasePage::MODALBODY).text
      return_hash[:footer_actions] = find(BasePage::MODALFOOTER).all('a').map(&:text)
      click_link action == true ? 'Ok' : 'Cancel'
    end
    return_hash
  end

  def actions_available_for(story_name)
    return_hash = {edit: nil, delete: nil}
    story_web_ele = find(USERDBROWSPAN, text: story_name)
    headings = find(TBHEADINGROW).all('th').map(&:text)
    action_index = headings.index(ACTIONS)
    return {} if NilClass === action_index
    action_ele = story_web_ele.find(:xpath, '../../..').all('td')[action_index]
    action_ele.all('a').each do |action_ele|
      if action_ele[:class] == ''
        return_hash[:edit] = true if action_ele.find(:xpath, '..')[:class].include? EDIT
      end
      return_hash[:edit] = true if action_ele[:class].include? EDIT
      return_hash[:delete] = true if action_ele[:class].include? DELETE
    end
    return_hash
  end

  def update_password_to(old_password:, new_password:)
    change_password unless has_css? PASSWORDMODAL
    find(USERCURRENTPASSWORD).set(old_password)
    find(USERPASSWORD).set(new_password)
    find(USERPASSWORDCONFRM).set(new_password)
    click_button SAVENEWPASSWORD
    sleep WAIT1
    return_error_details if has_css? PASSWORDMODAL
  end

  private

  def return_error_details
    within find(PASSWORDMODAL) do 
      find('form').all('div').map do |ele|
        {ele.find(LABEL).text => ele.find(SPAN).text} rescue nil
      end.uniq.compact 
    end
  end

  def submit_my_details
    page.find('input.user_dashboard_edit-btn').click
  end

  def change_password
    click_link CHANGEPASSWORD
  end

end
