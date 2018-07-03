json.id banner.id
json.position banner.position
json.pointToLink banner.link_path
json.imageUrls do |json|
  json.aspectRatio 2552.0/750.0
  json.sizes [:size_1, :size_2, :size_3, :size_4, :size_5, :size_6].each do |size|
    json.width get_banner_width(size)
    json.url banner.banner_image.url(size)
  end
end
