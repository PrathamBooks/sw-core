namespace :lists do
  desc "seeding lists created by orgs"
  task :seeding => :environment do
    csv = CSV.read("#{Rails.root}/PBLists.csv", {:headers=>false, :encoding => 'UTF-8'})
    list_data = {}
    stories_data = {}
    i = 0
    j = 0

    csv.each do |row|
      if row == "" || row == nil || row.empty? || !row.any?
        i += 1
        j = 0
        list_data[i] ={}
        stories_data[i]= {}
        next
      end
      if row[0] && row[0] == "Name"
        list_data[i][:title] = row[1].strip if row[1]
      elsif row[0] && row[0] == "Description"
        list_data[i][:description] = row[1].strip if row[1]
      elsif row[0] && row[0] == "Creator Org"
        begin
          item = Organization.find_by organization_name: row[1].strip
        rescue ActiveRecord::RecordNotFound => e
          item = nil
        end
        list_data[i][:organization] = item
      elsif row[0] && row[0] == "Category"
        if row[1] != nil || row[1].empty? || row[1] != ""
          items = []
          row[1].split(",").each do |i|
            begin
              item = ListCategory.find_by name: i.strip
            rescue ActiveRecord::RecordNotFound => e
              item = nil
            end
              items << item unless item.nil?
          end
          list_data[i][:categories] = items
        end
      elsif row[0] != nil || row[0].empty? || row[0] != ""
        begin
          story = Story.find(row[0].strip.to_i)
        rescue ActiveRecord::RecordNotFound => e
          puts e
          next
        end
        stories_data[i][j] = {}
        stories_data[i][j][:story_id] = story.id
        stories_data[i][j][:how_to_use] = row[1].strip if row[1]
        j = j+1
      end
    end

    list_data.each do |k, v|
      list_data[k][:user_id] = User.find_by_email("amna@prathambooks.org").id
      list = List.create!(v)
      stories_data[k].values.each do |data|
        data[:list_id] = list.id
      end
    end

    stories_data.each do |k, v|
      v.each do|a, b|
        ListsStory.create(v[a])
      end
    end

  end
end