namespace :stats do
  desc "Generate read/download data for African languages"
  lnames = ["Lusoga", "Kumam", "Runyoro / Runyakitara", "Runyankore", "Lumasaaba", "Kinyarwanda", "Luganda", "Dhopadhola", "Ateso"]
  task :african, [:csv_file] => :environment do |t, args|
    CSV.open(args[:csv_file], "w") do |c_obj|
      lnames.each do |lname|
        l = Language.find_by_name(lname)
        stories = Story.where(language:l, status:1)
        puts "#{lname}: #{stories.count}"
        c_obj << [lname]
        stories.each do |s|
          c_obj << [s.title, s.id, s.reads, s.downloads]
        end
      end
    end
  end
end
