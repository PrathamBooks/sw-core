json.title illustration.name
json.count 1
json.id illustration.id
json.imageUrls do |json|
  json.aspectRatio 320.0/240.0
  json.cropCoords illustration.crop_coords
  json.sizes illustration.image_sizes
end
json.illustrators illustration.illustrator_details
json.slug illustration.url_slug
