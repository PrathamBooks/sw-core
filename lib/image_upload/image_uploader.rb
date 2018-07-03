class ImageUpload::ImageUploader

  def check_input_file(dir, file_name)
    File.exist?(File.join(dir,file_name))
  end

  #Assign organization as copyright holder if no copyright holder specified
  def assign_organization_as_copyright_holder(organization)
    if organization.nil?
      return ["Unable to find the copyright holder with the email #{email}"]
    end
    return organization
  end

  def get_image_categories(text)
    result =  get_collection text, IllustrationCategory
    if result[:error] != nil
      raise result[:error]
    end
    return result[:items]
  end

  def get_image_styles(text)
    result =  get_collection text, IllustrationStyle
    if result[:error] != nil
      raise result[:error]
    end
    return result[:items]
  end

  def find_or_create_user(fname, lname, email, bio)
    return nil if fname.nil?
    user = User.find_by email: email.downcase
    if user == nil
      user = User.new(first_name: fname,last_name: lname,
                      email: email.downcase,password: "password", bio: bio)
      user.skip_confirmation_notification!
      unless user.save
        return ["Unable to save author " + user.errors.full_messages.join(", ")]
      end
    end
    return user
  end

  def find_or_create_person(first_name, last_name, organization)
    Person.where(first_name: first_name,last_name: last_name, created_by_publisher_id: get_publisher(organization).id).first ||
      Person.create(first_name: first_name,last_name: last_name, created_by_publisher_id: get_publisher(organization).id)
  end

  def person_as_illustrator(fname, lname, email, bio, organization)
    #return nil if fname.nil?
    if email.nil? || email.empty?
      return find_or_create_person(fname, lname, organization)
    else
      user = find_or_create_user(fname, lname, email, bio)
    end
    user.person || Person.create(first_name: user.first_name, last_name: user.last_name, user: user)
  end

  def get_illustrator(email, bio)
    user = User.find_by email: email.strip
    if user.nil?
      return {items: nil, error: "Unable to find the publisher with the email #{email}"}
    end
      user.bio = bio unless bio.nil? or bio.empty? or bio == ""
      user.save!
    return {items: (user.person || Person.create(first_name: user.first_name, last_name: user.last_name, user: user)), error: nil}
  end

  def upload(dir, c_fields, i_fields)
    begin
      # check image file
      if !check_input_file(dir, i_fields["s_no"])
        return ["Unable to find image with name #{i_fields["s_no"]}"]
      end
      result =  get_collection i_fields["category"], IllustrationCategory
      if result[:error] != nil
        return [result[:error]]
      end
      result =  get_collection c_fields["style"], IllustrationStyle
      if result[:error] != nil
        return [result[:error]]
      end

      #Get categories and styles
      categories = get_image_categories(i_fields["category"])
      styles     = get_image_styles(c_fields["style"])
      illustration_license           = Illustration.license_types["CC BY 4.0"]
      is_private = !c_fields["private"].empty? and !c_fields["private"].nil? and c_fields["private"] == "true" ? true : false

      # Find or create illustrators
      illustrators = []
      illustrator1 = get_illustrator(c_fields["illustrator_email1"], c_fields["illustrator_bio1"]) unless c_fields["illustrator_email1"].nil? or c_fields["illustrator_email1"].empty? or c_fields["illustrator_email1"] == ""
      illustrator2 = get_illustrator(c_fields["illustrator_email2"], c_fields["illustrator_bio2"]) unless c_fields["illustrator_email2"].nil? or c_fields["illustrator_email2"].empty? or c_fields["illustrator_email2"] == ""
      illustrator3 = get_illustrator(c_fields["illustrator_email3"], c_fields["illustrator_bio3"]) unless c_fields["illustrator_email3"].nil? or c_fields["illustrator_email3"].empty? or c_fields["illustrator_email3"] == ""
      if (illustrator1 && illustrator1[:error] != nil) || (illustrator2 && illustrator2[:error] != nil) || (illustrator3 && illustrator3[:error] != nil)
        results = illustrator1[:error] || illustrator2[:error] || illustrator3[:error]
        return [results]
      end
      illustrators << [illustrator1[:items]] if illustrator1
      illustrators << illustrator2[:items] if illustrator2
      illustrators << illustrator3[:items] if illustrator3
      # Find uploader, organizations
      organization  =  Organization.find_by email: c_fields["publisher"].strip
      uploader = User.find_by_email("pbsw@prathambooks.org")
      copyright_holder = assign_organization_as_copyright_holder(organization)
      illustration_attributes = {
        name: i_fields["name"],
        uploader: uploader,
        illustrators: illustrators.flatten.uniq,
        styles: styles,
        categories: categories,
        organization: organization,
        attribution_text: c_fields["attribution_text"],
        copy_right_year: c_fields["copyright_year"],
        license_type: illustration_license,
        tag_list: i_fields["tags"],
        org_copy_right_holder: copyright_holder,
        image_mode: is_private,
        is_bulk_upload: true
      }
      illustration =  Illustration.new(illustration_attributes)
      if illustration == nil
        return ["Unable to create illustration"]
      end

      # Set the image path here
      image = File.open(File.join(dir, i_fields["s_no"] ))
      illustration.image = image

      ActiveRecord::Base.transaction do
        if illustration.valid?
          illustration.save!
          story = Story.find(c_fields["story_id"].strip.to_i)
          page = story.pages.where(position: i_fields["s_no"].split(".").first).first
          illustration.process_crop!(page) if page
          return []
        else
          return  illustration.errors.full_messages
        end
      end
    end
    return []
  end


  private

  def get_collection text, klass
    items = []
    if text.nil? || text.empty?
      return {items: nil, error: "#{klass.name} can not be empty"}
    end
    text.split(",").each do |i|
      begin
        item = klass.find_by name: i.strip
      rescue ActiveRecord::RecordNotFound => e
        item = nil
      end
      if item == nil
        return {items: nil, error: "Unable to find #{klass.name} #{item}"}
      else
        items << item
      end
    end
    return { items: items, error: nil}
  end

end
