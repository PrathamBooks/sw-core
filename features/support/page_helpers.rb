module PageHelpers

  def page_click_link(*link_details)
    class_eval {
      method_name =  link_details.shift
      link_details = link_details.first
      link_name =  if link_details.is_a? Hash
          link_details[:link_name]
        else
          method_name.to_s.humanize
        end
      define_method(method_name.to_sym) do
        scope = if link_details.has_key? :scope
          link_details[:scope].is_a? String ? page_element(link_details[:scope]) : link_details[:scope]
        end
        func = 'if scope; scope.click_link "#{link_name}" ; else; click_link "#{link_name}" ; end ;'
        instance_eval func
      end
    }
  end

  def page_text_check(*text_details)
    class_eval {
      _method_name =  text_details.shift
      method_name = _method_name.to_s.downcase + '?'
      text_name =  if text_details.is_a? Hash
          text_details[:text_name]
        else
          text_details.first
        end
      define_method(method_name.to_sym) do
        has_text? text_name
      end
    }
  end

  def page_element(*ele_details)
    class_eval {
      method_name =  ele_details.shift
      options = ele_details.first
      finder, path = if options.is_a? Hash
                      finder_path = options.first
                      options.shift
                      finder_path
                    else
                      [Capybara.default_selector, options]
                    end
      extra_options = Hash === options ? options : {}
      define_method(method_name.to_sym) do
         find(finder, path, extra_options)
      end
    }
  end

  def page_elements(*eles_details)
    class_eval {
      method_name =  eles_details.shift
      options = eles_details.first
      finder, path = if options.is_a? Hash
                      finder_path = options.first
                      options.shift
                      finder_path
                    else
                      [Capybara.default_selector, options]
                    end
      extra_options = Hash === options ? options : {}
      define_method(method_name.to_sym) do
         all(finder, path, extra_options)
      end
    }
  end


end