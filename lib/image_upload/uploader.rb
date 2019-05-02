require 'fileutils'
require 'csv'

class ImageUpload::Uploader
  IMAGE_UPLOAD_QUEUE = 'image_upload'

  def check_input_file(dir, file_name)
    File.exist?(get_file_path(dir, file_name))
  end

  def get_file_path(dir, file_name)
    File.join(dir,file_name)
  end

  def open_csv(dir, file_name)
    csv_text = File.read(get_file_path(dir, file_name), encoding: "ISO8859-1:utf-8")
    CSV.parse(csv_text, :headers=>false)
  end

  def validate_common_fields(common_fields)
    results = []
    results << validate_copyright_year(common_fields["copyright_year"])
    results << validate_copyright_holder(common_fields["copyright_holder"])
    results << validate_organization(common_fields["publisher"])
    results << validate_attribution_text(common_fields["attribution_text"])
    results << validate_story(common_fields["story_id"])
  end

  def upload(csv_name, dir)

    unless check_input_file(dir, csv_name)
      return ["Unable to find csv file"]
    end
    csv = open_csv(dir, csv_name)
    common_fields = {}
    csv[0].each_with_index do |value, index|
      common_fields[value] = csv[1][index]
    end
    image_uploader = ::ImageUpload::ImageUploader.new
    results = validate_common_fields(common_fields)
    results = results.compact.uniq
    if !results.any?
      csv[3..csv.size].each_with_index do |image, index|
        if image == "" || image == nil || image.empty? || !image.any?
          next
        end
        indivdual_fields = {}
        csv[2].each_with_index do |value, i_index|
          indivdual_fields[value] = image[i_index] unless value.nil?
        end
        results =  image_uploader.upload(dir, common_fields, indivdual_fields)
        return results if results.any?
      end
    else
      return results
    end
    return []
  end

  private

  def validate_copyright_year(year)
    return "Copyright year column should not be empty" if year.nil? || year.empty?
  end

  def validate_copyright_holder(email)
    return "Copyright holder column should not be empty" if email.nil? || email.empty?
    begin
      holder = User.find_by email: email.strip
    rescue ActiveRecord::RecordNotFound => e
      holder = nil
    end
    if holder.nil?
      return "Unable to find the copyright holder with the email #{email}"
    end
  end

  def validate_organization(email)
    return "Publisher column should not be empty" if email.nil? || email.empty?
    begin
      organization = Organization.find_by email: email.strip
    rescue ActiveRecord::RecordNotFound => e
      organization = nil
    end
    if organization.nil?
      return "Unable to find the publisher with the email #{email}"
    end
  end

  def validate_attribution_text(text)
    return "Attribution text column should not be empty" if text.nil? || text.empty?
  end

  def validate_story(id)
    return "Story id column should not be empty" if id.nil? || id.empty?
    begin
      story = Story.find(id.strip.to_i)
    rescue ActiveRecord::RecordNotFound => e
      story = nil
    end
    if story.nil?
      return "Unable to find the story with the story id #{id}"
    end
  end

end
