class UnsubscribeUserFromMailingListJobJob < ActiveJob::Base
  queue_as :default

  def perform(user)

    mailchimp = Gibbon::API.new
    result = mailchimp.lists.unsubscribe({
                                           :id => ENV["MAILCHIMP_LIST_ID"],
                                           :email => {:email => user.email},
                                           :delete_member => true,
                                           :send_notify => true,
                                           :send_goodbye => true
                                         })
    Rails.logger.info("Unsubscribed #{user.email} from MailChimp") if result
  end
end
