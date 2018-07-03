class SubscribeUserToMailingListJob < ActiveJob::Base

  queue_as :default

  def perform(user)
    gb = Gibbon::API.new
    gb.lists.subscribe({:id => ENV["MAILCHIMP_LIST_ID"], :email => {:email => user.email}, :double_optin => false})
  end
end
