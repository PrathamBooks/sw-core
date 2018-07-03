class ChangePrathamLogo < ActiveRecord::Migration
  def change
    pub   = Publisher.find_by_email('admin@prathambooks.org')
    if(pub)
      logo  = File.open('app/assets/images/publisher_logos/Pratham Books.svg')
      pub.logo =  logo
      pub.save!
    end
  end
end
