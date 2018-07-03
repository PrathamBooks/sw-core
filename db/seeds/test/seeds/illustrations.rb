def create_illustrations(illustrations_count: 1, name: nil, person: nil, uploader_email: 'content_manager@sample.com')
  # Since only 10 images are available in illustrations folder
  illustrations_count = illustrations_count > 10 ? 10 : illustrations_count

  (1..illustrations_count).each do|illustration_idx|
    uploader = User.find_by_email(uploader_email)
    illustration_style = get_illustration_style
    illustration_category = get_illustration_category
    image_path = File.open(Rails.root.to_s + "/illustrations/image_#{illustration_idx}.jpg")
    title = name.nil? ? "Test_image_#{illustration_idx}" : name
    illustration = Illustration.create!(name: title, styles: [illustration_style], categories: [illustration_category],
            illustrators: [person], uploader_id: uploader.id, license_type: 'CC BY 4.0',
            image: image_path, attribution_text: 'sample automation text')
    illustration.save!
  end
  Illustration.reindex
end

def get_illustration_category
  illustration_category_id = rand(IllustrationCategory.count)+1
  rand_record = IllustrationCategory.find_by_id(illustration_category_id)
  return rand_record
end

def get_illustration_style
  illustration_style_id = rand(IllustrationStyle.count)+1
  rand_record = IllustrationStyle.find_by_id(illustration_style_id)
  return rand_record
end

user = User.find_by_email('illustrator@sample.com')
person = Person.create!(first_name: user.first_name, last_name: user.last_name, user_id: user.id)
person.save
create_illustrations({illustrations_count: 5, person: person})
