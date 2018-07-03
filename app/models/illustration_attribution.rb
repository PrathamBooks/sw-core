class IllustrationAttribution < Attribution
  attr_reader :page_number, :illustrators, :illustrators_id,
    :name, :license_type, :org_copy_right_holder, :photographers, :photographers_slug

  def initialize(page_number, illustrators, illustrators_id, copy_right_year,
                 name, license_type, url_slug, story, uploader,org_copy_right_holder,
                 photographers, photographers_slug)
    @page_number = page_number
    @illustrators = illustrators
    @illustrators_id = illustrators_id
    @copy_right_year = copy_right_year
    @name = name
    @license_type = license_type_name(license_type)
    @url_slug = url_slug
    @story = story
    @uploader = uploader
    @org_copy_right_holder = org_copy_right_holder
    @photographers = photographers
    @photographers_slug = photographers_slug
  end


  def copyright_holders
    if @org_copy_right_holder.present?
      return [@org_copy_right_holder]
    elsif @uploader.organization?
       return [@uploader.name]
    else
       @illustrators
    end
  end


  def copy_right_year
    @copy_right_year.blank? ? Time.now.year : @copy_right_year
  end

  def ==(other_object)
    if(other_object == nil)
      return false
    elsif (self.class != other_object.class)
      return false
    else
      return @page_number == other_object.page_number &&
        @illustrators.sort == other_object.illustrators.sort
    end
  end

  def license_type_name(license_type)
    license_types = {"CC BY 0" => "CC0", "CC BY 3.0" => "CC BY 3.0" , "CC BY 4.0" => "CC BY 4.0", "Public Domain" => "Public Domain"}
    license_types[license_type]
  end

end
