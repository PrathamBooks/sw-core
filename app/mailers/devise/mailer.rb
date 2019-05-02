class Devise::Mailer < ActionMailer::Base
     
  default from: "no-reply@prathambooks.org"
 
  def reset_password_instructions(record, token, opts={})
    @token = token
    mail(:to => record.email,:subject => "StoryWeaver: Reset password instructions") do |format|
      format.html { render :partial => '/devise/mailer/reset_password_instructions', :layout=>"email/layout", :locals=>{:resource=>record} }
    end
    return true
  end

  def confirmation_instructions(record, token, opts={})
    @token = token
    mail(:to => record.email,:subject => "Take a minute to confirm your StoryWeaver account!") do |format|
      format.html { render :partial => '/devise/mailer/confirmation_instructions', :layout=>"email/layout", :locals=>{:resource=>record} }
    end
    return true
  end

end