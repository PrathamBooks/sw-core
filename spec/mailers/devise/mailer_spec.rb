require "rails_helper"

RSpec.describe Devise::Mailer, :type => :mailer do
  class Devise::Mailer
    def mail(hash, &block)
      super(hash, &block).deliver
    end
  end

  before(:each) do
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @unsubscribed_user = FactoryGirl.create(:user, disable_mailer: true)
    @user = FactoryGirl.create(:user)
  end

  describe "#reset_password_instructions" do
    it "Should send reset password email even if the user is forgotten" do
      Devise::Mailer.reset_password_instructions(@user, "token")
      expect(ActionMailer::Base.deliveries).not_to be_empty
      Devise::Mailer.reset_password_instructions(@unsubscribed_user, "token")
      expect(ActionMailer::Base.deliveries.count).to eq 2
    end
  end

  describe "#confirmation_instructions" do
    it "Should send confirmation instructions email even if the user is forgotten" do
      Devise::Mailer.confirmation_instructions(@user, "token")
      expect(ActionMailer::Base.deliveries).not_to be_empty
      Devise::Mailer.confirmation_instructions(@unsubscribed_user, "token")
      expect(ActionMailer::Base.deliveries.count).to eq 2
    end
  end
end