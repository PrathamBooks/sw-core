class StoryUpload::StoryUploader
  def initialize(uploader,csv)
    @uploader = uploader
    @csv=csv
  end

  def check_file_exist(file)
    if !@uploader.check_input_file(file)
      raise "Unable to find Story with name #{file}"
    end
  end

  def check_story_exist(row)
    story = Story.joins(:authors).where(users: {email: row["Author Email 1"]}).where(title: row["Title"],language: Language.find_by(name: row["Language"]), reading_level: Story.reading_levels[row["Reading level"]]).first
    if story !=nil
      raise "Story already exists in the system"
    end
  end

  def find_or_create_user(name, email, bio)
    return nil if name.nil?
    first_name = first_name(name)
    last_name = last_name(name)
    user = User.find_by email: email.downcase
    if user == nil
      user = User.new(first_name: first_name,last_name: last_name,
                      email: email.downcase,password: "password", bio: bio)
      user.skip_confirmation_notification!
      unless user.save
        raise "Unable to save author " + user.errors.full_messages.join(", ")
      end
    end
    return user
  end

  def get_language(lang)
    language = Language.find_by name: lang
    if language == nil
      raise "Unable to find Language #{lang}"
    end
    return language
  end

  def check_reading_level(level)
    unless Story.reading_levels.include? level
      raise "Invalid Reading Level"
    end
  end

  def get_front_cover_template(template)
    cover_page_template= FrontCoverPageTemplate.find_by name: template
    if cover_page_template == nil
      raise "Unable to find cover page template - #{template}"
    end
    return cover_page_template
  end

  def check_synopsis(synopsis)
    if synopsis==nil || synopsis.empty?
      raise  "Synopsis can't be blank"
    end
  end

  def get_story_categories(text)
    result =  get_collection text, StoryCategory
    if result[:error] != nil
      raise result[:error]
    end
    categories = result[:items]
  end

  def root_story?(type)
    return type.nil? || type.strip.empty? || type.downcase == "root"
  end

  def translation?(type)
    return !type.nil? && type.downcase == "translation"
  end

  def relevel?(type)
    return !type.nil? && type.downcase == "re-level"
  end

  def get_story_from_server(csv_out,index)
    story = Story.joins(:authors).where(users: {email: csv_out["Author Email 1"][index]}).where(title: csv_out["Title"][index],language: Language.find_by(name: csv_out["Language"][index]), reading_level: Story.reading_levels[csv_out["Reading level"][index]]).first
    if story.nil?
      raise "The parent story is not uploaded."
    end
    return story
  end

  def find_parent_story(parent_epub,csv)
    raise "Unable to find parent story #{parent_epub}" if parent_epub.nil? || parent_epub.empty?
    csv.flush
    csv_out = @uploader.open_csv(@uploader.get_file_path("done"))
    csv_out["Story"].each_with_index do |story,index|
      next if story.nil? || story.empty?
      if story.strip == parent_epub.strip
        # raise "Parent story is not uploaded" if csv_out["Status"][index].nil? || csv_out["Status"][index].downcase.strip != "uploaded"
        return get_story_from_server(csv_out,index)
      end
    end
    raise "Unable to find parent story #{parent_epub}"
  end

  #Finding parent story from database with id
  def find_parent_with_parent_id(parent_id)
    story = Story.find(parent_id)
    if story.nil?
      raise "Unable to find the parent story in server with the parent id #{parent_id}"
    end
    return story
  end

  #Finding donor with the donor name
  def get_donor(name)
    donor = Donor.find_by name: name.strip
    if donor.nil?
      raise "Unable to find the donor with the name #{name}"
    end
    return donor
  end


  #Assign publisher as copyright holder if no copyright holder specified
  def assign_publisher_as_copyright_holder(publisher)
    user = User.find(publisher)
    if user.nil?
      raise "Unable to find the copyright holder with the email #{email}"
    end
    return user
  end

  def upload(index,csv_string)
    row = @csv[index]
    row["Status"]=""
    rows=nil
    parent=nil
    @illustrations=[]
    begin
      row["Story"].strip!
      check_file_exist row["Story"]
      check_story_exist row
      unless root_story?(row["Story Type"])
        parent = row["ParentId"].nil? || row["ParentId"].empty? ? find_parent_story(row["Parent Story"],csv_string) : find_parent_with_parent_id(row["ParentId"])
      end
      user1 = find_or_create_user(row["Author Name 1"],row["Author Email 1"],row["Author Bio 1"])
      user2 = find_or_create_user(row["Author Name 2"],row["Author Email 2"],row["Author Bio 2"])
      user3 = find_or_create_user(row["Author Name 3"],row["Author Email 3"],row["Author Bio 3"])
      language = get_language(row["Language"])
      check_reading_level(row["Reading level"])
      cover_page_template = get_front_cover_template(row["Template"]) unless translation?(row["Story Type"])
      check_synopsis(row["Synopsis"])
      story_defaults = {}
      story_defaults["Illustrator Name 1"] = row["Illustrator Name 1"]
      story_defaults["Illustrator Email 1"] = row["Illustrator Email 1"]
      story_defaults["Illustrator Bio 1"] = row["Illustrator Bio 1"]
      story_defaults["Illustrator Name 2"] = row["Illustrator Name 2"]
      story_defaults["Illustrator Email 2"] = row["Illustrator Email 2"]
      story_defaults["Illustrator Bio 2"] = row["Illustrator Bio 2"]
      story_defaults["Illustrator Name 3"] = row["Illustrator Name 3"]
      story_defaults["Illustrator Email 3"] = row["Illustrator Email 3"]
      story_defaults["Illustrator Bio 3"] = row["Illustrator Bio 3"]
      story_defaults["Illustration Style"] = row["Illustration Style"]
      story_defaults["Illustration License"] = row["Illustration License"].nil? ? "": (row["Illustration License"]).strip
      story_defaults["Illustration Attribution Text"] = row["Illustration Attribution Text"].nil? ? "": (row["Illustration Attribution Text"]).strip
      story_defaults["Copy Right Year"] = row["Copy Right Year"]
      story_defaults["Publisher"] = row["Publisher"]


      publisher = get_publisher(row["Publisher"])
      donor = row["Donor"].nil? || row["Donor"].empty? ? nil : get_donor(row["Donor"])
      categories = get_story_categories(row["Story categories"])

      story = nil
      @ebook = ::StoryUpload::Ebook.new(@uploader.get_file_path('inbox',row["Story"]),row["Text Align"])
      authors = [user1,user2,user3].compact.uniq
      story_attributes = {
          title: row["Title"],
          english_title: row["English Title"],
          reading_level: row["Reading level"],
          authors: authors,
          language: language,
          categories: categories,
          status: Story.statuses[:uploaded],
          synopsis: row["Synopsis"],
          publisher: publisher,
          donor: donor,
          credit_line: row["Credit Line"],
          attribution_text: row["Story Attribution"],
          copy_right_year: row["Copy Right Year"]
        }
      story =  Story.new(story_attributes)
      if story == nil
        row["Status"] = "Unable to create story"
        return generate_remaining_rows(index+1,row)
      end

      validate_no_of_pages(index) unless parent != nil &&  translation?(row["Story Type"])

      ActiveRecord::Base.transaction do
        pages = nil
        begin
          if parent != nil && translation?(row["Story Type"])
            story = parent.new_derivation(story_attributes,authors,publisher,"translated")
            story.parent=parent
            update_page_texts(story)
            rows = generate_remaining_rows(index+1,row)
          else
            result = upload_illustration(story_defaults,index,0,true)
            if result == nil || result[:illustration]==nil
              row["Status"] = "Cover page illustration - #{result[:error]}"
              return generate_remaining_rows(index+1,row)
            else
              page = FrontCoverPage.new(page_template: cover_page_template)
              page.save!
              story.pages << page
              epub_image= File.open(@ebook.get_file_path(@ebook.get_cover_page))
              result[:illustration].process_crop!(page, epub_image)
            end
            story.build_book cover_page_template
            result = create_pages(index, story_defaults)
            rows = result[:rows]
            if result[:has_error]
              rows[0]["Status"]="Failed to upload"  if row[0]["Status"].nil? || row[0]["Status"].empty?
              delete_illustrations_and_raise "Error while saving illustration"
            end
            pages = result[:pages]
            if relevel?(row["Story Type"])
              story.parent=parent
              story.derivation_type="relevelled"
            end
          end

          if story.save
            unless translation?(row["Story Type"])
              pages.each_with_index do |page,i|
                story.insert_page page
              end
            end
            rows[0]["Story ID"] = story.id
            rows[0]["Status"] = "Uploaded"
            PiwikEvent.create(
              category: 'Story',
              action: 'Create',
              name: 'Pratham'
            )
          else
            rows[0]["Status"] = story.errors.full_messages.join(", ")
            delete_illustrations_and_raise "Error while saving story #{story.errors.full_messages.join(", ")}"
          end
        rescue Exception => e
          puts e.backtrace
          row["Status"] = "Upload Failed: #{e} \n #{e.backtrace}" if row["Status"].nil? || row["Status"].empty?
          rows = generate_remaining_rows(index+1,row)
          delete_illustrations_and_raise "#{e}"
        ensure
          @ebook.destroy
        end
      end
    rescue Exception => e
      puts e.backtrace
      if rows == nil
        row["Status"] = "Upload Failed: #{e}\n #{e.backtrace}" if row["Status"].nil? || row["Status"].empty?
        return generate_remaining_rows(index+1,row)
      end
    end
    return  rows
  end

  def validate_no_of_pages(index)
    no_of_pages=0
    data = @ebook.get_page_data
    for i in (index+1)...@csv.size
      s = @csv["Story"][i]
      if !(s == "" || s == nil || s.empty?)
        break
      end
      no_of_pages+=1
    end
    unless no_of_pages == data.count
      raise "Total no. of story pages (#{data.count + 1}) is not matching with sheet #{no_of_pages + 1}"
    end
  end

  def delete_illustrations_and_raise(msg)
    @illustrations.each do |i|
      i.destroy
      i.run_callbacks(:commit)
    end
    raise msg
  end

  def generate_remaining_rows(index,current_row)
    rows = []
    rows << current_row
    for i in index...@csv.size
      story = @csv["Story"][i]
      if !(story == "" || story == nil || story.empty?)
        break
      end
      rows << @csv[i]
    end
    return rows
  end

  def update_page_texts(story)
    data = @ebook.get_page_data
    if data.size != story.number_of_story_pages
      raise "Parent story pages count #{story.number_of_story_pages} is not matching with current story pages #{data.size}"
    end
    data.each_with_index do |p,index|
      story.pages[index+1].content = p["content"]
    end
  end

  def create_pages(index, story_defaults)
    rows = []
    pages = []
    data = @ebook.get_page_data
    has_error=false
    page_number=0
    rows << @csv[index]
    for i in (index+1)...@csv.size
      page_number += 1
      s = @csv["Story"][i]
      if !(s == "" || s == nil || s.empty?)
        break
      end
      row = @csv[i]

      unless has_error
        template = PageTemplate.find_by(name: row["Template"])
        if template == nil
          row["Status"] = "Unable to find template : #{row["Template"]}"
          has_error=true
        else
          result = upload_illustration(story_defaults,i,page_number)
          if result == nil || result[:error]!=nil
            row["Status"] = "Failed to upload illustration: #{result[:error]}"
            has_error=true
          else
            content = data[page_number-1]["content"]
            if (content.nil?  || content.strip.empty?) && template.content_position != 'nil'
              row["Status"] = "Unable to find text for page"
              has_error=true
            else
              page = StoryPage.new(page_template: template,content: content)
              pages << page
              data = @ebook.get_page_data
              if result[:illustration] != nil
                epub_image= File.open(@ebook.get_file_path(data[page_number - 1]["image"]))
                illustration_crop = result[:illustration].process_crop!(page, epub_image)
              end
            end
          end
        end
      end
      rows << row
    end

    return {rows: rows, has_error: has_error, pages: pages}
  end

  def upload_illustration(story_defaults,i,page_number,coverpage=false)
    page_template = PageTemplate.find_by_name(@csv["Template"][i])
    return {illustration: nil, error: nil} if page_template.image_position=='nil'
    illustrator_name = get_or_default("Illustrator Name 1", i, story_defaults)
    illustration = Illustration.joins(:illustrators).where("illustrators_illustrations.person_id" => [Person.find_by(first_name: first_name(illustrator_name),last_name: last_name(illustrator_name))].compact).where(name: @csv["Illustration name"][i]).first
    unless illustration == nil
      return {illustration: illustration,error: nil}
    end
    user = Publisher.find_by email: story_defaults["Publisher"].strip
    result =  get_collection @csv["Illustration Categories"][i], IllustrationCategory
    if result[:error] != nil
      return {illustration: nil, error: result[:error]}
    end
    categories = result[:items]
    result =  get_collection get_or_default("Illustration Style", i, story_defaults), IllustrationStyle
    if result[:error] != nil
      return {illustration: nil, error: result[:error]}
    end

    license =  get_or_default("Illustration License", i, story_defaults).strip
    attribution_text =  get_or_default("Illustration Attribution Text", i, story_defaults).strip
    copy_right_year =  get_or_default("Copy Right Year", i, story_defaults)

    styles = result[:items]
    illustrator1 = person_as_illustrator(get_or_default("Illustrator Name 1", i, story_defaults),get_or_default("Illustrator Email 1", i, story_defaults),get_or_default("Illustrator Bio 1", i, story_defaults), story_defaults["Publisher"])
    illustrator2 = person_as_illustrator(get_or_default("Illustrator Name 2", i, story_defaults),get_or_default("Illustrator Email 2", i, story_defaults),get_or_default("Illustrator Bio 2", i, story_defaults), story_defaults["Publisher"])
    illustrator3 = person_as_illustrator(get_or_default("Illustrator Name 3", i, story_defaults),get_or_default("Illustrator Email 3", i, story_defaults),get_or_default("Illustrator Bio 3", i, story_defaults), story_defaults["Publisher"])
    illustration = Illustration.new(
      name: @csv["Illustration name"][i],
      categories: categories,
      styles: styles,
      uploader: user,
      illustrators: [illustrator1,illustrator2,illustrator3].compact,
      license_type: license,
      attribution_text: attribution_text,
      copy_right_year: copy_right_year
    )
    if coverpage
      image = @ebook.get_cover_page
      if image.empty?
        return {illustration: nil, error: "Unable to find coverpage"}
      end
      illustration.image= File.open(@ebook.get_file_path(image))
    else
      data = @ebook.get_page_data
      illustration.image= File.open(@ebook.get_file_path(data[page_number - 1]["image"]))
    end
    illustration.tag_list =  @csv["Illustration Tags"][i]
    if !illustration.save
      return {illustration: nil,error: illustration.errors.full_messages.join(", ")}
    end
    @illustrations << illustration
    return {illustration: illustration,error: nil}
  end

  def get_or_default(name, column_index, story_defaults)
    (@csv[name][column_index]).blank? ? story_defaults[name] : @csv[name][column_index]
  end

  def get_collection text, klass
    items = []
    if text.nil? || text.empty?
      return {items: nil, error: "#{klass.name} can not be empty"}
    end
    text.split(",").each do |i|
      item = klass.find_by name: i.strip
      if item == nil
        return {items: nil, error: "Unable to find #{klass.name} #{item}"}
      else
        items << item
      end
    end
    return { items: items, error: nil}
  end

  private

  def get_publisher(email)
    raise "Publisher column should not be nil" if email.nil? || email.empty?
    publisher = Publisher.find_by email: email.strip
    if publisher.nil?
      raise "Unable to find the publisher with the email #{email}"
    end
    return publisher
  end

  def find_or_create_person(first_name,last_name, publisher)
    Person.where(first_name: first_name,last_name: last_name, created_by_publisher_id: get_publisher(publisher).id).first ||
      Person.create(first_name: first_name,last_name: last_name, created_by_publisher_id: get_publisher(publisher).id)
  end

  def first_name(name)
    name.split(' ')[0]
  end

  def last_name(name)
    name.split(' ')[1..-1].join(' ')
  end

  def person_as_illustrator(name,email,bio, publisher)
    return nil if name.nil?
    first_name = first_name(name)
    last_name = last_name(name)
    if email.nil? || email.empty?
      return find_or_create_person(first_name,last_name, publisher)
    else
      user=find_or_create_user(name,email,bio)
    end
    user.person || Person.create(first_name: user.first_name, last_name: user.last_name, user: user)
  end
end
