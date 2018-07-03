json.ok true
json.data do |json|
  json.name @category.name
  json.slug @category.slug
  json.bannerImageUrl @category.category_banner.url(:original)
end
