FactoryGirl.define do
  factory :front_cover_page_template do
    sequence(:name) { |n| " Front Cover Page Template #{n}" }
    orientation "landscape"
    image_position "left"
    content_position "right"
    image_dimension 70.0
    content_dimension 30.0
  end
  factory :front_cover_page_template_2, class: :front_cover_page_template do
    name "front_cover_page_template_2"
    orientation "landscape"
    image_position "left"
    content_position "right"
    image_dimension 70.0
    content_dimension 30.0
  end
  factory :front_cover_page_template_portrait, class: :front_cover_page_template do
    name "front_cover_page_template_2"
    orientation "portrait"
    image_position "top"
    content_position "bottom"
    image_dimension 50.0
    content_dimension 50.0
  end
end
