namespace :db do
  desc "Generate user token"
  task :generate_user_token => :environment do
    User.all.each do|user|
      unless user.user_token
        user_token = UserToken.new
        user_token.user = user
        user_token.token =  SecureRandom.hex(16)
        user_token.save!
      end
    end
     @users = User.joins(:user_token).where(:user_tokens =>{:email_sent => false}).collect(&:email).count/1000
     @users.times.each do|off_set|
       Delayed::Job.enqueue Jobs::UnsubscribeEmails.new(1000, off_set)
     end
  end
end
