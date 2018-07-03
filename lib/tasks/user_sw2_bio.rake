namespace :db do
  desc "Create org users from csv"
  task :update_bio_sw2 => :environment do
    csv_text = File.read("#{Rails.root}/bios.csv")
    csv = CSV.parse(csv_text, :headers => true)
    csv.each_with_index do |row, index|
      if !row[2].blank?
        user = User.find_by_first_name(row[1].split(" ").first)
        if user && user.name == row[1]
          puts user.first_name
          user.bio = row[3]
          begin
            user.save!
          rescue Exception => e
            puts e
            next
          end
        else
          puts "User not found"
        end
       end
    end
  end
end