class TestMailer < ActionMailer::Base
  default from: "no-reply@example.com"
  def test
    mail(to: 'shashankteotia@gmail.com', subject: 'Test Email')
  end
end
