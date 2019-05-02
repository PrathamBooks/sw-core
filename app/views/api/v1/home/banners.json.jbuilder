json.ok true
json.data do |json|
  json.bannerImages do |json|
    json.partial! 'api/v1/home/banner', collection: @banner_images, as: :banner
  end
end