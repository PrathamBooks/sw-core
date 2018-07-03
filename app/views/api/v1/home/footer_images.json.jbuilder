json.ok true
json.data do |json|
  json.images @footer_images.each do |fi|
    illustration = fi.illustration
    json.title illustration.name
    json.id illustration.id
    json.aspectRatio 320.0/240.0
    json.cropCoords get_image_crop_coords(illustration)
    json.sizes [:large, :search].each do |size|
      json.height get_image_height(illustration, size)
      json.width get_image_width(illustration, size)
      json.url get_image_url(illustration, size)
    end
    json.slug illustration_slug(illustration)
  end
end
