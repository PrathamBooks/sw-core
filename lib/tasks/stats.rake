namespace :stats do
  desc "Generate published story stats"
  task :stories => :environment do
    psdate = Date.new(2015, 6, 1)
    edate = Date.today
    total_count = 0
    total_original_count = 0
    total_translation_count = 0
    CSV.open("/tmp/stories.csv", "w") do |c_obj|
      c_obj << ["End Date", "Original", "Tranalations", "Total"]
      while psdate <= edate
        esdate = Date.new(psdate.year, psdate.month, -1)
        total_count = Story.where(status: 1).where("published_at <= ?", esdate).count
        total_count += Story.where(status: 1).where(published_at: nil).count
        total_translation_count = Story.where(status: 1).where("published_at <= ?", esdate).where(derivation_type: "translated").count
        total_translation_count += Story.where(status: 1).where(published_at: nil).where(derivation_type: "translated").count
        total_original_count = total_count - total_translation_count
        c_obj << [psdate.strftime("%b-%Y").to_s, total_original_count, total_translation_count, total_count]
        psdate = esdate + 1
      end
    end
  end
end

require 'set'
namespace :stats do
  desc "Generate published language stats"
  task :languages => :environment do
    first_published_stories = []
    Language.all.each do |l|
      if Story.where(status: 1, language_id: l.id).where.not(published_at: nil).count > 0
        first_published_story = Story.find_by_sql("SELECT * FROM stories  WHERE language_id = " + l.id.to_s + " AND status = '1' ORDER BY published_at ASC LIMIT 1")[0]
        first_published_stories.append(first_published_story)
      end
    end
    psdate = Date.new(2015, 6, 1)
    edate = Date.today
    total_count = 0
    all_languages = Set.new
    while psdate <= edate
      esdate = Date.new(psdate.year, psdate.month, -1)
      prev_all_languages = Set.new(all_languages)
      new_languages = first_published_stories.find_all{|d| d.published_at.to_date >= psdate && d.published_at.to_date <= esdate}.map{|s| s.language.name}
      new_languages.each do |l|
        parts = l.split('-')
        parts.each do |p|
          if !all_languages.include?(p)
             all_languages.add(l)
          end
        end
      end
      real_new_languages = all_languages - prev_all_languages
      total_count = all_languages.size
      puts psdate.strftime("%b-%Y").to_s + "   " + real_new_languages.size.to_s + "   " + total_count.to_s + "   " + real_new_languages.to_a.join(',')
      psdate = esdate + 1
    end
  end
end

namespace :stats do
  desc "Generate Confirmed User stats"
  task :users => :environment do
    psdate = Date.new(2015, 6, 1)
    edate = Date.today
    while psdate <= edate
      esdate = Date.new(psdate.year, psdate.month, -1)
      user_count = User.where("confirmed_at <= ?", esdate).count
      puts psdate.strftime("%b-%Y").to_s + "   " + user_count.to_s 
      psdate = esdate + 1
    end
  end
end

namespace :stats do
  desc "Generate creator stats"
  task :creators => :environment do
    first_published_dates = []
    User.where.not(confirmed_at:nil).each do |user|
      ustories = user.stories.where(status: Story.statuses[:published]).where.not(published_at: nil)
      uills = []
      if user.person
        uills = user.person.illustrations
      end
      if ustories.size > 0 || uills.size > 0
        first_published_date_s = Date.today + 1
        first_published_date_u = Date.today + 1
        if ustories.size > 0
          first_published_date_s = ustories.sort{|s| s.published_at.to_date}[0].published_at.to_date
        end
        if uills.size > 0
          first_published_date_u = uills.sort{|s| s.created_at.to_date}[0].created_at.to_date
        end
        first_published_date = first_published_date_s < first_published_date_u ? first_published_date_s : first_published_date_u
        first_published_dates.append(first_published_date)
      end
    end
    psdate = Date.new(2015, 6, 1)
    edate = Date.today
    total_count = 0
    while psdate < edate
      esdate = Date.new(psdate.year, psdate.month, -1)
      lang_count = first_published_dates.find_all{|d| d.to_date >= psdate && d.to_date <= esdate}.size
      total_count += lang_count
      puts psdate.strftime("%b-%Y").to_s + "   " + lang_count.to_s + "   " + total_count.to_s
      psdate = esdate + 1
    end
  end
end

namespace :stats do
  desc "Generate institutional user stats"
  task :institutional_users => :environment do
    psdate = Date.new(2015, 6, 1)
    edate = Date.today
    total_count = 0
    while psdate <= edate
      esdate = Date.new(psdate.year, psdate.month, -1)
      user_count = InstitutionalUser.where("created_at <= ?", esdate).count
      puts psdate.strftime("%b-%Y").to_s + "   " + user_count.to_s 
      psdate = esdate + 1
    end
    all_ius = InstitutionalUser.all
    upgraded_ius_count = all_ius.find_all {|iu| iu.created_at.to_date > iu.user.created_at.to_date + 1}.size
    new_ius_count = all_ius.size - upgraded_ius_count
    puts "New Signups: " + new_ius_count.to_s + " Upgrades: " + upgraded_ius_count.to_s
  end
end

namespace :stats do
  desc "Generate published translation stats"
  task :translations => :environment do
    psdate = Date.new(2015, 6, 1)
    edate = Date.today
    total_count = 0
    while psdate <= edate
      esdate = Date.new(psdate.year, psdate.month, -1)
      story_count = Story.where(status: 1, published_at: psdate..esdate).where.not(ancestry: nil).count
      total_count += story_count
      puts psdate.strftime("%b-%Y").to_s + "   " + story_count.to_s + "   " + total_count.to_s
      psdate = esdate + 1
    end
  end
end
