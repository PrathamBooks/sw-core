def self.create_confirmed_user(user)
  user.skip_confirmation!
  user.save
end

create_confirmed_user User.new(first_name: 'Common Man', email:'user@sample.com', password: 'password', password_confirmation:'password')
create_confirmed_user User.new(first_name: 'Admin', email:'admin@sample.com', password: 'admin123', password_confirmation:'admin123', role: :admin)
create_confirmed_user User.new(first_name: 'Content Manager', email:'content_manager@sample.com',password: 'content_manager', password_confirmation:'content_manager', role: :content_manager)
create_confirmed_user User.new(first_name: 'Reviewer', email:'reviewer@sample.com',password: 'reviewer', password_confirmation:'reviewer', role: :reviewer)
create_confirmed_user User.new(first_name: 'Recommender', email:'recommender@sample.com',password: 'recommender', password_confirmation:'recommender', role: :recommender)
create_confirmed_user Publisher.new(first_name: 'Pratham Books', email:'admin@prathambooks.org',password: 'prathambooks', password_confirmation:'prathambooks', attribution: '© Pratham Books', logo: File.open('app/assets/images/publisher_logos/Pratham Books Logo.jpg'))
