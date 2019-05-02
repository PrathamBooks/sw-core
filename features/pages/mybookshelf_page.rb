class MybookshelfPage < ListPage
   
  EDIT = 'Edit'.freeze
  LISTDESCRIPTIONID = '#reading-list-list-desc-input'.freeze
  LISTDESWRAPPER = '.pb-reading-list__wrapper'.freeze
  LISTEDITACTIONS = 'please select available options : %s'.freeze
  LISTEDITBOOKS = '.pb-reading-list-entry--edit-active'.freeze
  STORYNAMEENTRY = '.pb-reading-list-entry__content'.freeze
  ALLSTORIES = '.pb-reading-list-entry__title'.freeze
  ENTRTFOOTER = '.pb-reading-list-entry__footer'.freeze
  DEFAULTACTION ='Yes'.freeze
  TEXTAREA ='.pb-text-field__input'.freeze
  CONTAINER = '.pb-reading-list-entry__content'.freeze
  BOOKSHELFLISTS ='.pb-reading-list-card__title'.freeze
  BOOKSHELFCONTAINER = '.pb-profile__lists'.freeze
  DELETEPOPUP = '.pb-modal__bounds'.freeze
  DELETEACTIONS = '.pb-modal__footer'.freeze
  BOOKSHELFWRAPPER = '.pb-reading-list__books'.freeze
  STORYINDEX = '.pb-reading-list-entry__index'.freeze
  DESCRIPTIONCONTENT = '.pb-reading-list-entry__desc'.freeze

 
  def list_edit
    click_link EDIT
  end

  def select_mybookshelf_list(list_name)
    find(BOOKSHELFCONTAINER).find(BOOKSHELFLISTS, text: list_name).click
  end

  def list_story_edit(story_name, action)
    web_ele = find(ALLSTORIES, text: /#{story_name}/i)
    footer_ele = web_ele.find(:xpath, '../../..').find(ENTRTFOOTER)
    footer_ele.all('a').select{|web_ele| web_ele.text == action}.first.click
  end

  def delete(option)
    within DELETEPOPUP do
      find(DELETEACTIONS).all('a').select{|element| element.text == option}.first.click
    end
  end

  def validate_list_stortedit(story_name)
    web_ele = find(ALLSTORIES, text: /#{story_name}/i)
    content = web_ele.find(:xpath, '../..').find(DESCRIPTIONCONTENT).text
    content.gsub('How to Use:', '').strip
  end

  def list_edit_updation(action)
    find(FLOATINGACTIONS).all('a').select{|web_ele| web_ele.text == action}.first.click
  end

  def fill_list_description(action_name)
    within LISTDESWRAPPER do
      find(LISTDESCRIPTIONID, visible: true).set(action_name)
    end
  end

  def list_story_position(story_name)
    web_ele = find(ALLSTORIES, text: /#{story_name}/i)
    story_serial_no = web_ele.find(:xpath, '../..')
    serial_no = story_serial_no.find(STORYINDEX).text
  end

  def fill_story_description(description)
    action_name = all(CONTAINER).each do |action_name|
      within  action_name do
        if has_css? TEXTAREA
          find(TEXTAREA, visible: true).set(description)
        end
      end
    end
  end

  def list_description_validation
    find('.pb-reading-list__desc').text
  end
end