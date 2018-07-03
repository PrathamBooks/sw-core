########################################################
require 'optparse'

options_hash = {}
OptionParser.new do |opts|
  opts.on("-g [GUIDE]", "--guide [GUIDE]") {|val| options_hash[:guide] = ''}
  opts.on("-t", "--token TOKEN") {|val| options_hash[:token] = val}
  opts.on("-o", "--origin ORIGIN") {|val| options_hash[:origin] = val}
  opts.on("-f", "--feedUrl OPDSURL") {|val| options_hash[:feedUrl] = val}  
  opts.on("-l", "--languageName LANGUAGE") {|val| options_hash[:languageName] = val}
  opts.on("-r", "--readLevel READLEVEL") {|val| options_hash[:readLevel] = val}
  opts.on("-p", "--publisherName ORGNAME") {|val| options_hash[:publisherName] = val}
  opts.on("-s", "--storyUuids ALLSTORIES", Array, "Array of arguments") {|val| options_hash[:storyUuids] = val}
end.parse!

puts "Parsed command line arguments:"
puts options_hash

if options_hash.empty?
  puts "no arguments passed, check guide by passing -g or --guide flag"
  exit
end

if options_hash.has_key?(:guide)
  puts "\nGOAL:"
  puts "this script intends to read story uuids from OPDS feed"
  puts "then fetch stories with those uuids along with dependent data"
  puts "next populate the data in current system DB\n"
  puts "\nUSAGE:"
  puts "following parameters are mandatory:"
  puts "token    => access token needed to fetch a story"
  puts "feedUrl  => url of opds feed"
  puts "origin   => domain or IP of the server where the API is located"
  puts "to fetch the story, you can either:"
  puts "1. provide storyUuids flag with argument as:"
  puts "  a. [*] to fetch all stories in the feed" 
  puts "  b. [SW-1,SW-10] to fetch specific stories with uuids given in array"
  puts "OR"
  puts "2. pass any combination of following filter flags:"
  puts "  a. languageName"
  puts "  b. readLevel"
  puts "  c. publisherName"
  puts "\nNOTE: if storyUuids flag is passed, filter flags are ignored"
  puts "\nthanks!\n"
  exit
end

if !options_hash.has_key?(:token) || !options_hash.has_key?(:feedUrl) || !options_hash.has_key?(:origin)
  puts "mandatory flags missing (token/feedUrl/origin)"
  exit
end

if !(options_hash.has_key?(:storyUuids) || options_hash.has_key?(:languageName) || options_hash.has_key?(:readLevel) || options_hash.has_key?(:publisherNames))
  puts "atleast 1 of the following flags is required: storyUuids/languageName/readLevel/publisherNames"
  exit
end

user_input_hash = options_hash
########################################################


require 'json'

# TODOS:
# Add Uuid column to model - D
# Add APIs for dependent data - D
# For a translated story, fetch the root story also and set it as parent and root - D
# For authors and other types of users, fetch only name - D
# 
# Fetch illustration from cloud and save
# Add methods to calculate uuid value for each model
# Add token-based authentication to all import APIs
# Check at script start whether the partner has the permission to fetch the story
# Error handling

# Assumption: Language, Author, Copy Right Holder, StoryCategory, Illustration already exist with passed IDs
def createCompleteStory(api_response, token, origin)
  lang_obj = getLanguage(api_response[:language_name], token, origin)
  story_category_objs = []
  api_response[:story_category_uuids].each {|uuid| story_category_objs << getStoryCategory(uuid, token, origin) }

  author_objs = []
  api_response[:author_uuids].each do |uuid|
    author_objs << getUser(uuid, token, origin)
  end

  org_obj = getOrganization(api_response[:organization_uuid], token, origin)
  
  story = Story.new(
    title:                api_response[:title], 
    attribution_text:     api_response[:attribution_text], 
    language:             lang_obj,
    english_title:        api_response[:english_title],
    reading_level:        api_response[:reading_level], 
    status:               api_response[:status],
    copy_right_year:      api_response[:copy_right_year], 
    synopsis:             api_response[:synopsis], 
    orientation:          api_response[:orientation],
    categories:           story_category_objs,
    authors:              author_objs,
    more_info:            api_response[:more_info],
    published_at:         Time.now.strftime("%Y-%m-%d %H:%M:%S"),
    tag_list:             api_response[:tag_list],
    organization:         org_obj,
    uuid:                 api_response[:uuid]
  )

  begin
    story.save!
  rescue => exception
    puts "Exception occurred!!\n\n"
    puts exception
    return nil
  end

  story_obj = story

  puts "ID of story created => #{story_obj.id}"

  index = 0
  page_objs = []
  api_response[:pages].each do |page|
    page_template = (page[:page_template_name] == nil) ? nil : getPageTemplate(page[:page_template_name], token, origin)
    obj = Page.new(
      content:                page[:content], 
      position:               page[:position], 
      type:                   page[:type],
      story:                  story_obj,
      page_template:          page_template,
    )
    copied_page = obj.tap(&:save)
    illustration_crop = (page[:illustration_crop_uuid] == nil) ? nil : getIllustrationCrop(page[:illustration_crop_uuid], copied_page, token, origin)    

    copied_page.illustration_crop = illustration_crop
    copied_page.save!

    page_objs << copied_page
    index += 1    
  end
  story_obj.pages = page_objs # assign pages to the story
  return story_obj
end

################### FETCH FROM REMOTE SERVER #################
def fetchIllustrationCrop(uuid, token, origin)
  return {} if uuid.nil?
  return fetchEntity("#{origin}/api/v0/illustration_crop/#{uuid}?token=#{token}")
end

def fetchIllustration(uuid, token, origin)
  return {} if uuid.nil?
  return fetchEntity("#{origin}/api/v0/illustration/#{uuid}?token=#{token}")
end

def fetchIllustrationStyle(uuid, token, origin)
  return {} if uuid.nil?
  return fetchEntity("#{origin}/api/v0/illustration_style/#{uuid}?token=#{token}")
end

def fetchIllustrationCategory(uuid, token, origin)
  return {} if uuid.nil?
  return fetchEntity("#{origin}/api/v0/illustration_category/#{uuid}?token=#{token}")
end

def fetchIllustrator(uuid, token, origin)
  return {} if uuid.nil?
  return fetchEntity("#{origin}/api/v0/illustrator/#{uuid}?token=#{token}")
end

def fetchStoryCategory(uuid, token, origin)
  return {} if uuid.nil?
  return fetchEntity("#{origin}/api/v0/story_category/#{uuid}?token=#{token}")
end

def fetchUser(uuid, token, origin)
  return {} if uuid.nil?
  return fetchEntity("#{origin}/api/v0/user/#{uuid}?token=#{token}")
end

def fetchOrganization(uuid, token, origin)
  return {} if uuid.nil?
  return fetchEntity("#{origin}/api/v0/organization/#{uuid}?token=#{token}")
end

def fetchOrganizationLogo(uuid, token, origin)
  return {} if uuid.nil?
  return fetchFile("#{origin}/api/v0/organization_logo/#{uuid}?token=#{token}") 
end

def fetchStoryCategoryBanner(uuid, token, origin)
  return {} if uuid.nil?
  return fetchFile("#{origin}/api/v0/story_category_banner/#{uuid}?token=#{token}") 
end

def fetchStoryCategoryHomeImage(uuid, token, origin)
  return {} if uuid.nil?
  return fetchFile("#{origin}/api/v0/story_category_home_image/#{uuid}?token=#{token}") 
end

def fetchIllustrationImg(uuid, token, origin)
  return {} if uuid.nil?
  return fetchFile("#{origin}/api/v0/illustration_image/#{uuid}?token=#{token}") 
end

def fetchIllustrationCropImg(uuid, token, origin)
  return {} if uuid.nil?
  return fetchFile("#{origin}/api/v0/illustration_crop_image/#{uuid}?token=#{token}") 
end

def fetchStoryUuid(id, token, origin)
  api_response = RestClient.get "#{origin}/api/v0/story_uuid/#{id}?token=#{token}"
  story_data = JSON.parse(api_response, :symbolize_names => true)
  return story_data[:uuid]
end

def fetchStory(uuid, token, origin)
  puts "calling story download API..."
  api_response = RestClient.get "#{origin}/api/v0/story/#{uuid}?token=#{token}"
  story_data = JSON.parse(api_response, :symbolize_names => true)
  return story_data
end

def fetchFile(api_endpoint)
  RestClient.get api_endpoint
end

def fetchEntity(api_endpoint)
  api_response = RestClient.get api_endpoint
  parsed_response = JSON.parse(api_response, :symbolize_names => true)
  return parsed_response 
end
########################################################

################## GET OBJECT METHODS ######################
def getPageTemplate(name, token, origin)
  page_template_obj = PageTemplate.find_by_name(name)
  if page_template_obj.nil?
    puts "ERROR: page template not present"
    return nil
  end
  return page_template_obj
end

def getOrganization(uuid, token, origin)
  org_obj = Organization.find_by_uuid(uuid)
  if org_obj.nil?
    puts "fetching organization with uuid => #{uuid}"                
    api_response = fetchOrganization(uuid, token, origin)
    obj = Organization.new(
      organization_name:    api_response[:organization_name],
      translated_name:      api_response[:translated_name],
      organization_type:    api_response[:organization_type],
      country:              api_response[:country],
      city:                 api_response[:city],
      number_of_classrooms: api_response[:number_of_classrooms],
      children_impacted:    api_response[:children_impacted],
      status:               api_response[:status],
      description:          api_response[:description],
      website:              api_response[:website],
      facebook_url:         api_response[:facebook_url],
      rss_url:              api_response[:rss_url],
      twitter_url:          api_response[:twitter_url],
      youtube_url:          api_response[:youtube_url],
      uuid:                 api_response[:uuid]
    )
    if api_response[:logo_path] != nil
      puts "fetching organization logo.."
      file_data = fetchOrganizationLogo(uuid, token, origin)
      File.open('tmp.jpg', 'wb') {|f| f.write(file_data)}
      obj.logo = File.open('tmp.jpg')
    end
    org_obj = obj.tap(&:save)
  end
  return org_obj
end

def getIllustrationStyle(uuid, token, origin)
  i_style_obj = IllustrationStyle.find_by_uuid(uuid)
  if i_style_obj.nil?
    puts "fetching illustration style with uuid => #{uuid}"                
    api_response = fetchIllustrationStyle(uuid, token, origin)
    obj = IllustrationStyle.new(
      name:             api_response[:name],
      translated_name:  api_response[:translated_name],
      uuid:             api_response[:uuid]
    )
    i_style_obj = obj.tap(&:save)
  end
  return i_style_obj
end

def getIllustrationCategory(uuid, token, origin)
  i_category_obj = IllustrationCategory.find_by_uuid(uuid)
  if i_category_obj.nil?
    puts "fetching illustration category with uuid => #{uuid}"                
    api_response = fetchIllustrationCategory(uuid, token, origin)
    obj = IllustrationCategory.new(
      name:             api_response[:name],
      translated_name:  api_response[:translated_name],
      uuid:             api_response[:uuid]
    )
    i_category_obj = obj.tap(&:save)
  end
  return i_category_obj
end

def getUser(uuid, token, origin)
  user_obj = User.find_by_uuid(uuid)
  if user_obj.nil?
    puts "fetching user with uuid => #{uuid}"                
    api_response = fetchUser(uuid, token, origin)
    obj = User.new(
      :name     => api_response[:name],
      :email    => "#{SecureRandom.hex}@gmail.com",
      :password => "#{SecureRandom.hex}",      
      :uuid     => api_response[:uuid]      
    )
    user_obj = obj.tap(&:save)
  end
  return user_obj
end

def getIllustrator(uuid, token, origin)
  i_illustrator_obj = Person.find_by_uuid(uuid)
  if i_illustrator_obj.nil?
    puts "fetching illustrator with uuid => #{uuid}"                
    api_response = fetchIllustrator(uuid, token, origin)
    puts api_response.inspect
    user_obj = getUser(api_response[:user_uuid], token, origin)
    obj = Person.new(
      user_id:    user_obj.id,
      first_name: api_response[:first_name], 
      last_name:  api_response[:last_name],
      uuid:       api_response[:uuid]
    )
    i_illustrator_obj = obj.tap(&:save)
  end
  return i_illustrator_obj
end

def getIllustration(uuid, token, origin)
  illustration_obj = Illustration.find_by_uuid(uuid)
  if illustration_obj.nil?
    puts "fetching illustration with uuid => #{uuid}"                
    api_response = fetchIllustration(uuid, token, origin)

    i_style_objs = []
    api_response[:style_uuids].each {|uuid| i_style_objs << getIllustrationStyle(uuid, token, origin)}

    i_category_objs = []
    api_response[:category_uuids].each {|uuid| i_category_objs << getIllustrationCategory(uuid, token, origin)}

    i_illustrator_objs = []
    api_response[:illustrator_uuids].each {|uuid| i_illustrator_objs << getIllustrator(uuid, token, origin)}

    puts api_response.inspect
    uploader_obj = getUser(api_response[:uploader_uuid], token, origin)

    obj = Illustration.new(
      :name                     => api_response[:name],
      :uploader                 => uploader_obj,
      :attribution_text         => api_response[:attribution_text],
      :license_type             => api_response[:license_type],
      :image_processing         => api_response[:image_processing],
      :flaggings_count          => api_response[:flaggings_count],
      :copy_right_year          => api_response[:copy_right_year],
      :image_meta               => api_response[:image_meta],
      :reads                    => api_response[:reads],         
      :is_pulled_down           => api_response[:is_pulled_down],         
      :copy_right_holder_id     => api_response[:copy_right_holder_id],
      :image_mode               => api_response[:image_mode],         
      :storage_location         => nil,
      :is_bulk_upload           => api_response[:is_bulk_upload],         
      :smart_crop_details       => api_response[:smart_crop_details],
      :organization_id          => api_response[:organization_id],
      :org_copy_right_holder_id => api_response[:org_copy_right_holder_id],
      :album_id                 => api_response[:album_id],
      :styles                   => i_style_objs,
      :categories               => i_category_objs,
      :illustrators             => i_illustrator_objs,
      :uuid                     => api_response[:uuid]
    )
    if api_response[:image_path] != nil
      file_data = fetchIllustrationImg(uuid, token, origin)
      puts file_data.class
      File.open('tmp.jpg', 'wb') {|f| f.write(file_data)}
      obj.image = File.open('tmp.jpg')
    end
    illustration_obj = obj.tap(&:save)
    illustration_obj.reindex
    puts "IO: #{illustration_obj.inspect}"
    return illustration_obj
  end
  return illustration_obj
end

def getIllustrationCrop(uuid, page, token, origin)
  illustration_crop_obj = IllustrationCrop.find_by_uuid(uuid)
  if illustration_crop_obj.nil?
    puts "fetching illustration crop with uuid => #{uuid}"            
    api_response = fetchIllustrationCrop(uuid, token, origin)
    illustration_obj = getIllustration(api_response[:illustration_uuid], token, origin)
    obj = IllustrationCrop.new(
      illustration_id:    illustration_obj.id,
      crop_details:       api_response[:crop_details],
      image_meta:         api_response[:image_meta],
      storage_location:   nil,
      smart_crop_details: api_response[:smart_crop_details],
      uuid:               api_response[:uuid]      
    )
    obj.pages = []
    obj.pages << page
    if api_response[:image_path] != nil
      file_data = fetchIllustrationCropImg(uuid, token, origin)
      puts file_data.class      
      File.open('tmp.jpg', 'wb') {|f| f.write(file_data)}
      obj.image = File.open('tmp.jpg')
    end
    illustration_crop_obj = obj.tap(&:save)
  else
    illustration_crop_obj.pages << page
  end
  return illustration_crop_obj
end

def getLanguageFont(script, token, origin)
  lang_font_obj = LanguageFont.find_by_script(script)
  if lang_font_obj.nil?
    puts "ERROR: language font not present"
    return nil
  end
  return lang_font_obj
end

def getLanguage(name, token, origin)
  lang_obj = Language.find_by_name(name)
  if lang_obj.nil?
    puts "ERROR: language not present"
    return nil
  end
  return lang_obj
end

def getStoryCategory(uuid, token, origin)
  story_category_obj = StoryCategory.find_by_uuid(uuid)
  if story_category_obj.nil?
    puts "fetching story category with uuid => #{uuid}"                
    api_response = fetchStoryCategory(uuid, token, origin)
    obj = StoryCategory.new(
      :name           => api_response[:name],
      :translated_name=> api_response[:translated_name],
      :private        => api_response[:private],
      :active_on_home => api_response[:active_on_home],
      :uuid           => api_response[:uuid]
    )
    if api_response[:banner_path] != nil
      file_data = fetchStoryCategoryBanner(uuid, token, origin)
      puts file_data.class      
      File.open('tmp.jpg', 'wb') {|f| f.write(file_data)}
      obj.category_banner = File.open('tmp.jpg')
    end

    if api_response[:home_image_path] != nil
      file_data = fetchStoryCategoryHomeImage(uuid, token, origin)
      puts file_data.class      
      File.open('tmp.jpg', 'wb') {|f| f.write(file_data)}
      obj.category_home_image = File.open('tmp.jpg')
    end

    story_category_obj = obj.tap(&:save)
  end
  return story_category_obj
end

# ############################ Parse OPDS Feed ##############################
require "opds"
story_uuids = []

puts "Feed URL is : #{user_input_hash[:feedUrl]}"

opds_obj = OPDS.access(user_input_hash[:feedUrl])

if !opds_obj
  puts "unable to access OPDS catalog"
  exit
end

# filter out story uuids from the feed based on user input
if user_input_hash.has_key?(:storyUuids)
  if user_input_hash[:storyUuids][0] == "*"
    opds_obj.entries.each {|e| story_uuids << e.id}
  else
    user_input_hash[:storyUuids].each do |story_uuid|
      opds_obj.entries.each do |e|
        if story_uuid == e.id && !story_uuids.include?(story_uuid)
          story_uuids << story_uuid
        end
      end
    end
  end
else
  filter_count = (user_input_hash & [:languageName, :readLevel, :publisherName]).size
  opds_obj.entries.each do |e|
    match = 0
    if user_input_hash.has_key?(:languageName)
      if user_input_hash[:languageName] == e.dcmetas["language"][0][0]
        match += 1
      end
    end
    if user_input_hash.has_key?(:publisherName)
      if user_input_hash[:publisherName] == e.dcmetas["publisher"][0][0]
        match += 1
      end
    end
    if user_input_hash.has_key?(:readLevel)
      if user_input_hash[:readLevel] == e.summary
        match += 1
      end
    end
    if (match == filter_count)
      story_uuids << e.id 
    end
  end
end

if story_uuids.count < 1
  puts "No matching stories found in the feed..."
  exit
end

puts story_uuids

origin = user_input_hash[:origin]

token = user_input_hash[:token]

story_uuids.each do |story_uuid|
  if Story.find_by_uuid(story_uuid) == nil
    story_data = fetchStory(story_uuid, token, origin)
    story_obj = createCompleteStory(story_data, token, origin)
    if story_obj == nil
      puts "\n\nunable to save story with uuid : #{story_uuid}"
      next
    end
    story_obj.reindex
    # fetch current story's root story if it has ancestors, save it, link it
    if !story_data[:ancestry].nil?
      root_story_id = story_data[:ancestry].split("/").first
      root_story_uuid = fetchStoryUuid(root_story_id, token, origin)
      root_story_obj = Story.find_by_uuid(root_story_uuid)
      if root_story_obj == nil
        root_story_data = fetchStory(root_story_uuid, token, origin)
        root_story_obj = createCompleteStory(root_story_data, token, origin)
        if root_story_obj == nil
          puts "\n\nunable to save root story with uuid : #{root_story_obj}"
          next
        end
        root_story_obj.reindex
      else
        puts "root story with UUID : #{root_story_uuid} already exists"
      end
      story_obj.ancestry = "#{root_story_obj.id}"
      story_obj.save!
    end
  else
    puts "story with UUID : #{story_uuid} already exists"
  end
end
