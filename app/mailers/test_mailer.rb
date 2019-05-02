class TestMailer < ActionMailer::Base
  default from: "no-reply@prathambooks.org"
  def test
    mail(to: 'shashankteotia@gmail.com', subject: 'Test Email')
  end
end
