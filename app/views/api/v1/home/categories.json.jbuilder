json.ok true
json.data @story_categories do |cat|
  json.name I18n.t("categories."+cat.name)
  json.queryValue cat.name
  json.slug cat.slug
  json.imageUrls do |json|
    json.aspectRatio 304.0/130.0
    json.sizes [:size_1, :size_2, :size_3, :size_4].each do |size|
      json.width get_category_home_width(size)
      json.url cat.category_home_image.url(size)
    end
  end
end