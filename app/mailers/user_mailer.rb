class UserMailer < ActionMailer::Base
  default from: "no-reply@prathambooks.org"
  after_filter :stop_sending_emails, :except   => [:root_story_derivation_for_org, :child_story_derivation_for_org, :unsubscribe]

  def pulled_down_story_mail(user,story,reasons)
    @reasons = reasons
    @user = user
    @story = story
    mail(:to => @user.email, :subject => "Your story has been pulled down") do |format|
      format.html { render :partial => "/user_mailer/pulled_down_story_mail", :layout=>"email/layout" }
    end
  end

  def pulled_down_illustration_mail(illustrator,illustration,reasons)
    @reasons = reasons
    @illustrator = illustrator
    @illustration = illustration
    mail(:to => @illustrator.email, :subject => "Your image has been pulled down") do |format|
      format.html { render :partial => "/user_mailer/pulled_down_illustration_mail", :layout=>"email/layout" }
    end
  end

  def pulled_down_story_by_illustration_mail(author,illustration,story,pages)
    @author = author
    @story = story
    @illustration = illustration
    @pages = pages
    mail(:to => @author.email, :subject => "An image used in your story has been pulled down") do |format|
      format.html { render :partial => "/user_mailer/pulled_down_story_by_illustration_mail", :layout=>"email/layout" }
    end
  end

  def flagged_story(content_manager,story,user,reason,path)
    @story = story
    @user = user
    @reason = reason
    @path = path
    mail(:to => content_manager, :subject => "StoryWeaver: A story has been flagged #{@path.present? ? 'by reviewer' : ''} ") do |format|
      format.html { render :partial => "/user_mailer/flagged_story", :layout=>"email/layout" }
    end
  end

  def flagged_illustration(content_manager,illustration,user,reason)
    @illustration = illustration
    @user = user
    @reason = reason
    mail(:to => content_manager, :subject => "StoryWeaver: An illustration has been flagged") do |format|
      format.html { render :partial => "/user_mailer/flagged_illustration", :layout=>"email/layout" }
    end
  end

  def published_story(content_managers, story)
    @story = story
    mail(:to => content_managers, :subject => "StoryWeaver: Story got published") do |format|
      format.html {render :partial => "/user_mailer/published_story", :layout => "email/layout"}
    end
  end

  def re_publish_story(content_managers, story, user)
    @story = story
    @user = user
    mail(:to => content_managers, :subject => "StoryWeaver: Story got re-published") do |format|
      format.html {render :partial => "/user_mailer/re_publish_story", :layout => "email/layout"}
    end
  end

  def story_flagger_email(flaggers,story)
    @flaggers = flaggers
    @story = story
    mail(:to => @flaggers.email, :subject => "StoryWeaver: Story you flagged has been pulled down") do |format|
      format.html {render :partial => "/user_mailer/story_flagger_email", :layout => "email/layout"}
    end
  end  

  def illustration_flagger_email(flaggers,illustration)
    @flaggers = flaggers
    @illustration = illustration
    mail(:to => @flaggers.email, :subject => "StoryWeaver: Illustration you flagged has been pulled down") do |format|
      format.html {render :partial => "/user_mailer/illustration_flagger_email", :layout => "email/layout"}
    end
  end  

  def re_published_story_email(content_managers, story, user)
    @story = story
    @user = user
    mail(:to => content_managers, :subject => "StoryWeaver: Story got Re-published") do |format|
      format.html {render :partial => "/user_mailer/re_published_story_email", :layout => "email/layout"}
    end
  end

  def story_re_publish_email_to_flagger(flaggers, story)
    @flaggers = flaggers
    @story = story
    mail(:to => @flaggers.email, :subject => "StoryWeaver: Story you flagged got Re-published") do |format|
      format.html {render :partial => "/user_mailer/story_re_publish_email_to_flagger", :layout => "email/layout"}
    end
  end

  def submitted_story_mail_to_managers(managers, story, contest)
    @story = story
    @contest = contest
    mail(:to => managers, :subject => "StoryWeaver: Story got submitted to "+@contest.name) do |format|
      format.html {render :partial => "/user_mailer/submitted_story_email", :layout => "email/layout"}
    end
  end

  def submitted_story_mail_to_user(user, story, contest)
    @user = user
    @story = story
    @contest = contest
    mail(:to => @user.email, :subject => "StoryWeaver: Story got submitted to "+@contest.name) do |format|
      format.html {render :partial => "/user_mailer/submitted_story_mail_to_user", :layout => "email/layout"}
    end
  end

  def assign_language_reviewer(reviewer,language)
    @reviewer = reviewer
    @language = language
    mail(:to => @reviewer.email, :subject => "Thanks for agreeing to rate stories") do |format|
      format.html {render :partial => "/user_mailer/assign_language_reviewer_mail", :layout => "email/layout"}
    end
  end

  def assign_language_translator(translator,language)
    @translator  = translator
    @language    = language
    mail(:to => @translator.email, :subject => "Thanks for being a translator on StoryWeaver!") do |format|
      format.html {render :partial => "/user_mailer/assign_language_translator_mail", :layout => "email/layout"}
    end
  end

  def reviewer_rating_comment(content_managers,reviewer_comments,date)
    @reviewer_comments = reviewer_comments
    @date = date
     mail(:to => content_managers, :subject => "Community Reviewers' Activity as on #{ @date }") do |format|
      format.html {render :partial => "/user_mailer/reviewer_rating_comment_mail", :layout => "email/layout"}
    end
  end

  def uploaded_illustration(content_managers,illustration)
    @illustration = illustration
    mail(:to => content_managers, :subject => "StoryWeaver: Illustration has been uploaded") do |format|
      format.html {render :partial => "/user_mailer/uploaded_illustration", :layout => "email/layout"}
    end
  end

  def organization_user_signup(content_managers,organization,current_user)
    @organization = organization
    @current_user = current_user
    mail(:to => content_managers, :subject => "StoryWeaver: New organisational user has signed up") do |format|
      format.html {render :partial => "/user_mailer/organization_user_signup_mail", :layout => "email/layout"}
    end
  end

  def root_story_derivation(emails, story, root_story)
    emails_list = emails
    @root_story = root_story
    @story = story
    mail(:to => emails_list, :subject => "StoryWeaver: New version of the story has been created") do |format|
      format.html {render :partial => "/user_mailer/root_story_derivation", :layout => "email/layout"}
    end
  end

  def root_story_derivation_for_org(email, story, root_story)
    @root_story = root_story
    @story = story
    mail(:to => email, :subject => "StoryWeaver: New version of the story has been created") do |format|
      format.html {render :partial => "/user_mailer/root_story_derivation", :layout => "email/layout"}
    end
  end

  def derivation_of_child_story(emails, story, root_story)
    emails_list = emails
    @root_story = root_story
    @story = story
    mail(:to => emails_list, :subject => "Here is what's been happening with your story!") do |format|
      format.html {render :partial => "/user_mailer/derivation_of_child_story", :layout => "email/layout"}
    end
  end

  def child_story_derivation_for_org(email, story, root_story)
    @root_story = root_story
    @story = story
    mail(:to => email, :subject => "Here is what's been happening with your story!") do |format|
      format.html {render :partial => "/user_mailer/derivation_of_child_story", :layout => "email/layout"}
    end
  end

  def translators_one_week_mail(translators, story, name)
    @story       = story
    @translator  = translators
    @name  = name
    mail(:to => @translator, :subject => "Forgotten about your translation?") do |format|
      format.html {render :partial => "/user_mailer/translators_one_week_mail", :layout => "email/layout"}
    end
  end

  def translators_three_weeks_mail(translators, story, name)
    @story       = story
    @translator  = translators
    @name  = name
    mail(:to => @translator, :subject => "Last reminder about your translation!") do |format|
      format.html {render :partial => "/user_mailer/translators_three_weeks_mail", :layout => "email/layout"}
    end
  end

  def publisher_story_mail_to_authors(authors,story)
     @story = story
     mail(:to => authors, :subject => "Your story has been published!") do |format|
      format.html {render :partial => "/user_mailer/publisher_story_mail_to_authors", :layout => "email/layout"}
    end
  end

  def publisher_story_mail_to_illustrators(illustrators, story)
    @story = story
     mail(:to => illustrators, :subject => "The story with your illustrations has been published!") do |format|
      format.html {render :partial => "/user_mailer/publisher_story_mail_to_illustrators", :layout => "email/layout"}
    end
  end

  def cm_daily_mail(managers, daily_email_info)
    @daily_email_info = daily_email_info
    mail(:to => managers, :subject => "StoryWeaver: Here is your update for today") do |format|
      format.html {render :partial => "/user_mailer/cm_daily_email", :layout => "email/layout"}
    end
  end
 
  def cm_monthly_mail(managers, monthly_email_info)
    @monthly_email_info = monthly_email_info
    mail(:to => managers, :subject => "StoryWeaver: Here is your monthly update") do |format|
      format.html {render :partial => "/user_mailer/cm_monthly_email", :layout => "email/layout"}
    end
  end
 
  def cm_comparison_two_months_mail(managers, email_info_1st_month, email_info_2nd_month, name_of_1st_month, name_of_2nd_month)
    @email_info_1st_month = email_info_1st_month
    @email_info_2nd_month = email_info_2nd_month
    @name_of_1st_month = name_of_1st_month
    @name_of_2nd_month = name_of_2nd_month
    mail(:to => managers, :subject => "StoryWeaver: Here is your two months update") do |format|
      format.html {render :partial => "/user_mailer/cm_comparison_two_months_mail", :layout => "email/layout"}
    end
  end

  def unsubscribe(user)
   @user = user
   mail(:to => user.email, :subject => "StoryWeaver: GDPR mailer") do |format|
      format.html {render :partial => "/user_mailer/unsubscribe_emails", :layout => "email/layout",  :locals => {:unsubscribe => true} }
    end
  end

  def reading_level_mismatch_mail(story, author_name, author_email)
    @story = story
    @author_name = author_name
    mail(:to => author_email, :subject => "We have a suggestion for your story") do |format|
      format.html {render :partial => "/user_mailer/reading_level_mismatch_mail", :layout => "email/layout"}
    end
  end

  def started_video_processing(story, user)
    @story = story
    @user = user
    mail(:to => user.email, :subject => "StoryWeaver: Story video processing has started") do |format|
      format.html {render :partial => "/user_mailer/started_video_processing", :layout => "email/layout"}
    end
  end

  def video_processing_success(story, user)
    @story = story
    @user = user
    mail(:to => user.email, :subject => "StoryWeaver: Your video story has generated successfully") do |format|
      format.html {render :partial => "/user_mailer/video_processing_success", :layout => "email/layout"}
    end
  end

  def error_in_video_processing(story, user)
    @story = story
    @user = user
    mail(:to => user.email, :subject => "StoryWeaver: Story video processing has failed") do |format|
      format.html {render :partial => "/user_mailer/error_in_video_processing", :layout => "email/layout"}
    end
  end

 private

  def stop_sending_emails
    to = User.where(email: [mail.to], disable_mailer: false).collect(&:email)
    if to.empty?
      mail.perform_deliveries = false
    else
      mail.to = to.join(",")
    end
  end

end
