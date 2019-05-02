require 'capybara/dsl'

module SWExtendedCapybaraFinders
  include Capybara::DSL

  ERRMSGFORFILEDWEBELE = "Field Name && Web Element are empty, Pass atleast one to start with".freeze
  TEXTMISSING = 'Page doesnt have text specified :: %s'.freeze

  DEFAULTTEXTAREA = "Text field Default value SW-Automation".freeze
  DEFAULTTEXTVALUE = "Text field Default value SW-Automation".freeze
  INPUT = 'input'.freeze
  LABEL = 'label'.freeze

  def get_type_of_sw field_name 
    parent_webele = find(LABEL, text: /#{humanize(field_name)}/i ).find(:xpath, '..')
    get_type(parent_webele)
  end

#this is a common template where we can update or set or clear the text field
  def sw_text_field(webele: nil, field_name: "", method: :get, field_value: DEFAULTTEXTVALUE)
    sp_raise_error if NilClass === webele && field_name.empty?
    sp_error_text_missing(field_name) unless has_text? field_name
    webele = find_by_label(field_name) if NilClass === webele
    webele_input = webele.find(:xpath, '..').find(INPUT)
    case method
    when :get
      webele_input[:value]
    when :set
      webele_input.set field_value
      webele_input.find(:xpath, "../../..").click
    when :clear
      webele_input.set ''
    end
  end

  def sw_text_area(webele: nil, field_name: "", method: :get, field_value: DEFAULTTEXTAREA)
    sp_raise_error if NilClass === webele && field_name.empty?
    sp_error_text_missing(field_name) unless has_text? field_name
    webele = find_by_label(field_name) if NilClass === webele
    text_area_webele = webele.find(:xpath, '..').find('textarea')
    case method
    when :get
      text_area_webele.text
    when :set
      text_area_webele.set field_value
    when :clear
      text_area_webele.set ''
    end
  end

  def sw_multi_select(webele: nil, field_name: "", field_value: '', method: :get)
    sp_raise_error if NilClass === webele && field_name.empty?
    sp_error_text_missing(field_name) unless has_text? field_name
    webele = find_by_label(field_name) if NilClass === webele
    parent_ele = webele.find(:xpath, '..')
    case method
    when :get
      parent_ele.find('button').text
    when :set
      parent_ele.click
      parent_ele.find(INPUT).set field_value
      parent_ele.find('ul').all('li', text: field_value, exact: true).first.click
      parent_ele.click
    when :clear
      parent_ele.set '' #wont work
    end
  end

  def sw_check_box(webele: nil, field_name: "", method: :get)
    sp_raise_error if NilClass === webele && field_name.empty?
    sp_error_text_missing(field_name) unless has_text? field_name
    webele = find('span', text: field_name, exact: true) if NilClass === webele
    webele_input = webele.find(:xpath, '..').find("#{LABEL} #{INPUT}")
    check_flag = webele_input['checked'] == 'true'
    case method
    when :get
      check_flag
    when :check
      webele_input.click unless check_flag
    when :uncheck
      webele_input.click if check_flag
    end
  end

  private

  def humanize(str)
    str.gsub(" ","_").split("_").map(&:capitalize).join(' ')
  end

  def find_by_label(field_name)
    find(LABEL, text: /#{field_name}/i)
  end

  def sp_raise_error
    raise ERRMSGFORFILEDWEBELE
  end

  def sp_error_text_missing(field_name)
    raise TEXTMISSING % [field_name ]
  end

  def get_type(web_ele)
    parent_ele = web_ele
    return 'sw_multi_select' if parent_ele.has_css?('select', visible: false)
    return 'sw_text_area' if parent_ele.has_css?('textarea')
    input_flag = parent_ele.has_css?(INPUT)
    if input_flag
      case parent_ele.find(INPUT)['type']
      when 'text'
        return 'sw_text_field'
      end
    end
    'sw_check_box'
  end

end
