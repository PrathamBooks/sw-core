class Jobs::UnsubscribeEmails < Struct.new(:users_limit, :off_set)
  def perform
    users = User.limit(users_limit).offset(off_set*users_limit).joins(:user_token).where(:user_tokens =>{:email_sent => false})
    users.each do|user|
      unless user.user_token.email_sent
        UserMailer.unsubscribe(user).deliver
        user.user_token.email_sent = true
        user.user_token.save!
      end
    end
  end
  def queue_name
    'unsubscribe_email'
  end
end

