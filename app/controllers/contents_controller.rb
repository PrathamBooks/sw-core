class ContentsController < ApplicationController
  def about
    @menu = "about"
    @sub_menu = "about"
    check_locale(params[:action])
  end

  def story_weaver_and_you
    @menu = "about"
    @sub_menu = "story_weaver_and_you"
  end

  def campaign
    @menu = "about"
    @sub_menu = "campaign"
  end

  def past_campaigns
    @menu = "about"
    @sub_menu = "campaign"
    @sub_menu_child = 'past_campaigns'
  end

  def our_supporters
    @menu = "about"
    @sub_menu = "our_supporters"
  end

  def prathambooks
    @menu = "about"
    @sub_menu = "prathambooks"
  end

  def open_content
    @menu = "open_content"
  end

  def faqs
    @menu = "help"
    @sub_menu = "faqs"
    check_locale(params[:action])
  end

  def tutorials
    @menu = "help"
    @sub_menu = "tutorials"
  end

  def translation_tools_and_tips
    @menu = "help"
    @sub_menu = "translation_tools_and_tips"
  end

  def dos_and_donts
    @menu = "help"
    @sub_menu = "dos_and_donts"
  end

  def reading_levels
    @menu = "help"
    @sub_menu = "reading_levels"
  end

  def terms_and_conditions
    @menu = "terms of use"
    @sub_menu = "terms_and_conditions"
  end

  def privacy_policy
    @menu = "terms of use"
    @sub_menu = "privacy_policy"
  end
  
  def disclaimer
    @menu = "help"
    @sub_menu = "disclaimer"
  end
  
  def press
    @menu = "press"
    @sub_menu = "press"
  end

  def in_the_news
    @menu = "press"
    @sub_menu = "in_the_news"
  end
  
  def archive
    @menu = "press"
    @sub_menu = "archive"
  end

  def news_arch_2016
    @menu = "press"
    @sub_menu = "news_arch_2016"
  end

  def news_arch_2015
    @menu = "press"
    @sub_menu = "news_arch_2015"
  end
  
  def picture_gallery
    @menu = "press"
    @sub_menu = "picture_gallery"
  end
  
  def contact
    @menu = "contact"
    @sub_menu = "contact"
  end
  
  def careers
    @menu = "contact"
    @sub_menu = "careers"
  end
  
  def feedback_and_comments
    @menu = "contact"
    @sub_menu = "feedback_and_comments"
  end
  
  def volunteer
    @menu = "contact"
    @sub_menu = "volunteers"
  end

  def weave_a_story_campaign
    @menu = "about"
    @sub_menu = "campaign"
    @sub_menu_child = 'past_campaigns'
  end

  def wonder_why_week
    @menu = "about"
    @sub_menu = "campaign"
    @sub_menu_child = 'past_campaigns'
  end

  def check_locale(action)
    respond_to do |format|
      format.html { render "#{action}_#{I18n.locale.to_s}" }
    end
  end

end
