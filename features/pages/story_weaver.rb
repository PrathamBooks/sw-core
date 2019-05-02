class StoryWeaver

  METHODS = ['login_page', 'base_page', 'read_page', 'story_details', 'story_read_popup',
             'create_page', 'profile_dash_board', 'user_dash_board', 'dash_board', 'image_page',
              'image_details_page','list_page', 'mybookshelf_page','read_along_page'].freeze

  def get_class_name(_method_name)
    Object.const_get( _method_name.split('_').map(&:capitalize) * '' )
  end

  METHODS.each do |method_name|
    class_eval {
      define_method(method_name.to_sym) do
        get_class_name(method_name).new
      end
    }
  end
end
