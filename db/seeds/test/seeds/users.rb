def self.create_confirmed_user(user)
  user.skip_confirmation!
  user.save
end

def self.create_org_user(user)
  user.organization = Organization.first || Organization.create(organization_name: "org")
  user.organization_roles = 'publisher'
  create_confirmed_user(user)
end
create_org_user User.new(first_name: 'Pratham Books', email:'orguser@prathambooks.org', password: 'password', password_confirmation:'password')
create_confirmed_user User.new(first_name: 'Common Man', email:'user@sample.com', password: 'password', password_confirmation:'password')
create_confirmed_user User.new(first_name: 'Test user', email:'test@sample.com', password: 'password', password_confirmation:'password')
create_confirmed_user User.new(first_name: 'Content Manager', email:'content_manager@sample.com',password: 'content_manager', password_confirmation:'content_manager', role: "content_manager", site_roles: "content_manager")
create_confirmed_user User.new(first_name: 'Pratham Books', email:'admin@prathambooks.org', password: 'prathambooks', logo: File.open('app/assets/images/publisher_logos/Pratham Books Logo.jpg'))
create_confirmed_user User.new(first_name: 'Working Draft', email:'autotranslate@yopmail.com', password: 'password', password_confirmation:'password')
create_confirmed_user User.new(first_name: 'illustrator', email:'illustrator@sample.com', password: 'password', password_confirmation:'password')
