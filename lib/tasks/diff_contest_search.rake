namespace :contests do
  desc "Generate difference between results returned by tags and search for a contest"
  task :diff => :environment do
    url = "https://storyweaver.org.in/stories/"
    ss = Story.search('1000books', operator: "or", where:{:status=>[:published]}).hits.map{|h| h["_id"]}.map{|id| id.to_i}
    st = Story.tagged_with("#1000Books").find_all{|s| s.status == "published"}.map{|s| s.id}
    puts "Number of published stories on search: #{ss.count}"
    puts "Number of published stories on dashboard: #{st.count}"
    if (ss - st).count > 0
      puts "Stories in search but not in dashboard"
      (ss - st).each do |s|
        story = Story.find(s)
        puts url + story.to_param
      end
    end
    if (st - ss).count > 0
      puts "Stories in dashboard but not in search"
      (st - ss).each do |s|
        story = Story.find(s)
        puts url + story.to_param
      end
    end
  end
end
