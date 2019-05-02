require "rails_helper"

RSpec.describe UserMailer, :type => :mailer do
  before(:each) do
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @user = FactoryGirl.create(:user, email: 'testuser@mirafra.com')
    @person = FactoryGirl.create(:person_with_account, :user => @user)
    @illus_style = FactoryGirl.create(:style, :name => "Style1")
    @illus_cat = FactoryGirl.create(:illustration_category)
    @illustration = FactoryGirl.create(:illustration, :illustrators => [@person], :name => "Illustration1", :categories => [@illus_cat], :tag_list => "Tag_1", :styles => [@illus_style], :reads => 5)
    @story = create_story({illustration: @illustration, story_title: "Test story"})
    @content_manager = FactoryGirl.create(:content_manager)
    @unsubscribed_user = FactoryGirl.create(:user, disable_mailer: true)
    Illustration.reindex
    Story.reindex
    User.reindex
    @all_cm_emails = -> { User.content_manager.collect(&:email) }
  end

  describe "#pulled_down_story_mail" do
    it "Should send pulled down story email to user" do
      UserMailer.pulled_down_story_mail(@user, @story, ["pull down reasons"]).deliver
      expect(ActionMailer::Base.deliveries).not_to be_empty
    end

    it "Should not send email if the user is unsbcribed" do
      UserMailer.pulled_down_story_mail(@unsubscribed_user, @story, ["pull down reasons"]).deliver
      expect(ActionMailer::Base.deliveries).to be_empty
    end
  end

  describe "#pulled_down_illustration_mail" do
    it "Should email when the illustration is pulled down" do
      UserMailer.pulled_down_illustration_mail(@user, @illustration, ["pull down reasons"]).deliver
      expect(ActionMailer::Base.deliveries).not_to be_empty
    end

    it "Should not send email if the user is unsubscribed" do
      UserMailer.pulled_down_illustration_mail(@unsubscribed_user, @illustration, ["pull down reasons"]).deliver
      expect(ActionMailer::Base.deliveries).to be_empty
    end
  end

  describe "#pulled_down_story_by_illustration_mail" do
    it "Should email when story is pulled down" do
      UserMailer.pulled_down_story_by_illustration_mail(@user, @illustration, @story, @story.pages[1]).deliver
      expect(ActionMailer::Base.deliveries).not_to be_empty
    end

    it "Should not send email if the user is unsubscribed" do
      UserMailer.pulled_down_story_by_illustration_mail(@unsubscribed_user, @illustration, @story, @story.pages[1]).deliver
      expect(ActionMailer::Base.deliveries).to be_empty
    end
  end

  describe "#flagged_story" do
    it "Should send email if the story is flagged" do
      UserMailer.flagged_story(@all_cm_emails.call , @story, @user, ["flagged reasons"], "",).deliver
      expect(ActionMailer::Base.deliveries).not_to be_empty
    end

    it "Should not send email to cm if he/she is unsubscribed" do
      cm = FactoryGirl.create(:content_manager, disable_mailer: true)
      UserMailer.flagged_story(cm.email, @story, @unsubscribed_user, ["flagged reasons"], "",).deliver
      expect(ActionMailer::Base.deliveries).to be_empty
    end
  end

  describe "#flagged_illustration" do
    it "Should sent email to cm when illustration is flagged" do
      UserMailer.flagged_illustration(@all_cm_emails.call, @illustration , @user, ["flagged illustration reasons"]).deliver
      expect(ActionMailer::Base.deliveries).not_to be_empty
    end

    it "Should not send email to cm if he/she is unsubscribed" do
      cm = FactoryGirl.create(:content_manager, disable_mailer: true)
      UserMailer.flagged_illustration(cm.email, @illustration , @user, ["flagged illustration reasons"]).deliver
      expect(ActionMailer::Base.deliveries).to be_empty
    end
  end

  describe "#published_story" do
    it "Should email to cm if the story a new story published" do
      UserMailer.published_story(@all_cm_emails.call, @story).deliver
      expect(ActionMailer::Base.deliveries).not_to be_empty
    end

    it "should not send email to the cm if he/she is unsubscribed" do
      cm = FactoryGirl.create(:content_manager, disable_mailer: true)
      UserMailer.published_story(cm.email, @story).deliver
      expect(ActionMailer::Base.deliveries).to be_empty
    end
  end

  describe "#re_publish_story" do
    it "should sent email to cm only to the user who are not unsubscribed" do
      cm = FactoryGirl.create(:content_manager, disable_mailer: true)
      UserMailer.re_publish_story([@content_manager.email, cm.email], @story, @user.first_name).deliver
      expect(ActionMailer::Base.deliveries.count).to be 1
    end
  end

  describe "#story_flagger_email" do
    it "Should email to flagger if the story is flagged" do
      UserMailer.story_flagger_email(@user, @story).deliver
      expect(ActionMailer::Base.deliveries).not_to be_empty
    end

    it "Should not send email to the flagger if the user is unsubscribed" do
      UserMailer.story_flagger_email(@unsubscribed_user, @story).deliver
      expect(ActionMailer::Base.deliveries).to be_empty
    end
  end

  describe "#illustration_flagger_email" do
    it "Should send email to the user if the illustration is flagged" do
      UserMailer.illustration_flagger_email(@user, @illustration).deliver
      expect(ActionMailer::Base.deliveries).not_to be_empty
    end

    it "Should not send email if the user is unsubscribed" do
      UserMailer.illustration_flagger_email(@unsubscribed_user, @illustration).deliver
      expect(ActionMailer::Base.deliveries).to be_empty
    end
  end

  describe "#re_published_story_email" do
    it "Should not send email to the cms who are unsubscribed" do
      cm = FactoryGirl.create(:content_manager, disable_mailer: true)
      UserMailer.re_published_story_email(@all_cm_emails.call, @story, @user.first_name).deliver
      expect(ActionMailer::Base.deliveries.count).to be 1
      expect(ActionMailer::Base.deliveries.first.to).to eq [@content_manager.email]
    end
  end

  describe "#story_re_publish_email_to_flagger" do
    it "Should send email to user if the story is republished" do
      UserMailer.story_re_publish_email_to_flagger(@user, @story).deliver
      expect(ActionMailer::Base.deliveries).not_to be_empty
    end
    it "Should not send email to the user if he/she is unsubscribed" do
      UserMailer.story_re_publish_email_to_flagger(@unsubscribed_user, @story).deliver
      expect(ActionMailer::Base.deliveries).to be_empty
    end
  end

  describe "#submitted_story_mail_to_managers" do
    it "Should not send email to the cms who are unsubscribed" do
      cm = FactoryGirl.create(:content_manager, disable_mailer: true)
      contest = FactoryGirl.create(:contest)
      UserMailer.submitted_story_mail_to_managers(@all_cm_emails.call, @story, contest).deliver
      expect(ActionMailer::Base.deliveries.count).to be 1
      expect(ActionMailer::Base.deliveries.first.to).to eq [@content_manager.email]
    end
  end

  describe "#submitted_story_mail_to_user" do
    before(:each) do
      @contest = FactoryGirl.create(:contest)
    end

    it "Should email to the user if story is submitted" do
      UserMailer.submitted_story_mail_to_user(@user, @story, @contest).deliver
      expect(ActionMailer::Base.deliveries).not_to be_empty
    end

    it "should not send email if the user is unsubscribed" do
      UserMailer.submitted_story_mail_to_user(@unsubscribed_user, @story, @contest).deliver
      expect(ActionMailer::Base.deliveries).to be_empty
    end
  end

  describe "#assign_language_reviewer" do
    before(:each) do
      @language = FactoryGirl.create(:language)
    end

    it "Should email to the reviewer after agreering to rate the story" do
      reviewer = FactoryGirl.create(:reviewer)
      UserMailer.assign_language_reviewer(reviewer, @language).deliver
      expect(ActionMailer::Base.deliveries).not_to be_empty
    end

    it "Should not send email to the reviewer if he/she is unsubscribed" do
      disable_reviewer = FactoryGirl.create(:reviewer, disable_mailer: true)
      UserMailer.assign_language_reviewer(disable_reviewer, @language).deliver
      expect(ActionMailer::Base.deliveries).to be_empty
    end
  end

  describe "#assign_language_translator" do
    before(:each) do
      @language = FactoryGirl.create(:language)
    end

    it "Should email to the translator after the story is translated" do
      translator = FactoryGirl.create(:translator)
      UserMailer.assign_language_translator(translator, @language).deliver
      expect(ActionMailer::Base.deliveries).not_to be_empty
    end

    it "should not send email to translator if he/she is unsubscribed" do
      translator = FactoryGirl.create(:translator, disable_mailer: true)
      UserMailer.assign_language_translator(translator, @language).deliver
      expect(ActionMailer::Base.deliveries).to be_empty
    end
  end

  describe "#reviewer_rating_comment" do
    it "Should send review comments email to cms who are not unsubscribed" do
      cm = FactoryGirl.create(:content_manager, disable_mailer: true)
      language = FactoryGirl.create(:language)
      rc = FactoryGirl.create(:reviewer_comment, story: @story, language_id: language.id, user: @user)
      UserMailer.reviewer_rating_comment([cm.email, @content_manager.email], [rc], Date.today).deliver
      expect(ActionMailer::Base.deliveries.count).to be 1
      expect(ActionMailer::Base.deliveries.first.to).to eq [@content_manager.email]
    end
  end

  describe "#uploaded_illustration" do
    it "Should send emails to cms who are not unsubscribed, when illustration is uploaded" do
      cm = FactoryGirl.create(:content_manager, disable_mailer: true)
      UserMailer.uploaded_illustration(@all_cm_emails.call, @illustration).deliver
      expect(ActionMailer::Base.deliveries.count).to be 1
      expect(ActionMailer::Base.deliveries.first.to).to eq [@content_manager.email]
    end
  end

  describe "#organization_user_signup" do
    it "Should send email to all cms who are not unsubscribed, when a new organization is created" do
      org = FactoryGirl.create(:organization)
      cm = FactoryGirl.create(:content_manager, disable_mailer: true)
      UserMailer.organization_user_signup(@all_cm_emails.call, org, @user).deliver
      expect(ActionMailer::Base.deliveries.count).to be 1
      expect(ActionMailer::Base.deliveries.first.to).to eq [@content_manager.email]
    end
  end

  describe "#root_story_derivation" do
    it "Should send email to all cms who are not unsubscribed, when a new story is derived from root story" do
      child_story = FactoryGirl.create(:story)
      child_story.parent = @story
      child_story.save!
      cm = FactoryGirl.create(:content_manager, disable_mailer: true)
      UserMailer.root_story_derivation(@all_cm_emails.call, child_story, @story).deliver
      expect(ActionMailer::Base.deliveries.count).to be 1
      expect(ActionMailer::Base.deliveries.first.to).to eq [@content_manager.email]
    end
  end

  describe "#root_story_derivation_for_org" do
    it "Should send email to all the users even he/she is unsubscribed in StoryWeaver" do
      child_story = FactoryGirl.create(:story)
      child_story.parent = @story
      child_story.save!
      cm = FactoryGirl.create(:content_manager, disable_mailer: true)
      mail_list = [cm.email, @content_manager.email]
      UserMailer.root_story_derivation_for_org(mail_list, child_story, @story).deliver
      expect(ActionMailer::Base.deliveries.map(&:to).flatten).to match_array mail_list
    end
  end
  
  describe "#derivation_of_child_story" do
    it "Should not send emails to the user who are not unsubscribed" do
      child_story = FactoryGirl.create(:story)
      child_story.parent = @story
      child_story.save!
      cm = FactoryGirl.create(:content_manager, disable_mailer: true)
      mail_list = [cm.email, @content_manager.email]
      UserMailer.derivation_of_child_story(mail_list, child_story, @story).deliver
      expect(ActionMailer::Base.deliveries.map(&:to).flatten).to eq [ @content_manager.email]
    end
  end

  describe "#child_story_derivation_for_org" do
    it "Should not send email if the user is unsubscribed" do
      child_story = FactoryGirl.create(:story)
      child_story.parent = @story
      child_story.save!
      cm = FactoryGirl.create(:content_manager, disable_mailer: true)
      mail_list = [cm.email, @content_manager.email]
      UserMailer.child_story_derivation_for_org(mail_list, child_story, @story).deliver
      expect(ActionMailer::Base.deliveries.map(&:to).flatten).to match_array mail_list
    end
  end

  describe "#translators_one_week_mail" do
    it "Should send emails to user regarding translatoions which are in translation phase for a week and the users are not unsubscribed" do
      mail_list = [@unsubscribed_user.email, @user.email]
      UserMailer.translators_one_week_mail(mail_list, @story, "Story Weaver story").deliver
      expect(ActionMailer::Base.deliveries.map(&:to).flatten).to match_array [@user.email]
    end
  end

  describe "#translators_three_weeks_mail" do
    it "Should send emails to user regarding translatoions which are in translation phase for a 3weeks and the users are not unsubscribed" do
      mail_list = [@unsubscribed_user.email, @user.email]
      UserMailer.translators_three_weeks_mail(mail_list, @story, "Story Weaver story").deliver
      expect(ActionMailer::Base.deliveries.map(&:to).flatten).to match_array [@user.email]
    end
  end

  describe "#publisher_story_mail_to_authors" do
    it "Should send email to author if the story is published" do
      UserMailer.publisher_story_mail_to_authors(@user.email, @story).deliver
      expect(ActionMailer::Base.deliveries).not_to be_empty
    end

    it "Should not send email to the author if he/she is unsubscribed" do
      UserMailer.publisher_story_mail_to_authors(@unsubscribed_user.email, @story).deliver
      expect(ActionMailer::Base.deliveries).to be_empty
    end
  end

  describe "#publisher_story_mail_to_illustrators" do
    it "Should send email to the illustrators if the story is published" do
      UserMailer.publisher_story_mail_to_illustrators(@user.email, @story).deliver
      expect(ActionMailer::Base.deliveries).not_to be_empty
    end

    it "Should not send email to the illustrators if he/she is unsubscribed" do
      UserMailer.publisher_story_mail_to_illustrators(@unsubscribed_user.email, @story).deliver
      expect(ActionMailer::Base.deliveries).to be_empty
    end
  end

  context "CM status mail" do
    before(:each) do
      @cm = FactoryGirl.create(:content_manager, disable_mailer: true)
      @mail_list = [@cm.email, @content_manager.email]
    end
    describe "#cm_daily_mail" do
      it "Should email to cms regarding daily update who are not unsubscribed" do
        UserMailer.cm_daily_mail(@mail_list, {}).deliver
        expect(ActionMailer::Base.deliveries.map(&:to).flatten).to match_array [@content_manager.email]
      end
    end

    describe "#cm_monthly_mail" do
      it "Should email to cms regarding monthly update who are not unsubscribed" do
        UserMailer.cm_monthly_mail(@mail_list, {}).deliver
        expect(ActionMailer::Base.deliveries.map(&:to).flatten).to match_array [@content_manager.email]
      end
    end

    describe "#cm_comparison_two_months_mail" do
      it "Should email to cms regarding two monthes update who are not unsubscribed" do
        UserMailer.cm_comparison_two_months_mail(@mail_list, {}, {}, "JAN", "FEB").deliver
        expect(ActionMailer::Base.deliveries.map(&:to).flatten).to match_array [@content_manager.email]
      end
    end
   end
end