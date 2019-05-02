require 'optparse'

options_hash = {}
OptionParser.new do |opts|
  opts.on("-g [GUIDE]", "--guide [GUIDE]") {|val| options_hash[:guide] = ''}
  opts.on("-t", "--token TOKEN") {|val| options_hash[:token] = val}
  opts.on("-u", "--partner_url ORIGIN") {|val| options_hash[:partner_url] = val}
  opts.on("-o", "--organization_id ORGID") {|val| options_hash[:organization_id] = val}
  opts.on("-p", "--platform_code PLATFORMCODE") {|val| options_hash[:platform_code] = val}
end.parse!

puts "Parsed command line arguments:"
puts options_hash

if options_hash.empty?
  puts "no arguments passed, check guide by passing -g or --guide flag"
  exit
end

if options_hash.has_key?(:guide)
  puts "\nEXAMPLE USAGE:\n"
  puts "rails runner analytics_data_fetch_and_populate.rb --organization_id=2 --platform_code=SW --token=q1w2e3r4 --partner_url=https://awesome-site.com\n"
  exit
end

if !(options_hash.has_key?(:partner_url) && options_hash.has_key?(:token) && 
  options_hash.has_key?(:organization_id) && options_hash.has_key?(:platform_code))
  puts "\nFollowing parameters are mandatory: --partner_url, --organization_id, --token, --platform_code\n"
  exit
end

organization_id = options_hash[:organization_id]

partner_url = options_hash[:partner_url]

token = options_hash[:token]

platform_code = options_hash[:platform_code]

puts "Calling API to get read count for all SW stories"
api_response = RestClient.get "#{partner_url}/api/v0/analytics/story_read_count?token=#{token}&platform_code=#{platform_code}"
api_data = JSON.parse(api_response)
api_data.each do |story_uuid, read_count|
  partner_story_reads_obj = PartnerStoryReads.where(:organization_id => organization_id).where(:story_uuid => story_uuid).first
  if partner_story_reads_obj == nil
    partner_story_reads_obj = PartnerStoryReads.new(:organization_id => organization_id, :story_uuid => story_uuid, :reads => read_count)
  else
    partner_story_reads_obj.reads = read_count
  end
  partner_story_reads_obj.save!
end

puts "Calling API to get download count for all SW stories"
api_response = RestClient.get "#{partner_url}/api/v0/analytics/story_download_count?token=#{token}&platform_code=#{platform_code}"
api_data = JSON.parse(api_response)
api_data.each do |story_uuid, download_count_hash|
  partner_story_downloads_obj = PartnerStoryDownloads.where(:organization_id => organization_id).where(:story_uuid => story_uuid).first
  if partner_story_downloads_obj == nil
    partner_story_downloads_obj = PartnerStoryDownloads.new(
        :organization_id             => organization_id, 
        :story_uuid             => story_uuid, 
        :low_res_pdf_downloads  => download_count_hash["low_res_pdf"], 
        :high_res_pdf_downloads => download_count_hash["high_res_pdf"],
        :epub_downloads         => download_count_hash["epub"], 
        :total_downloads        => download_count_hash["low_res_pdf"] + download_count_hash["high_res_pdf"] + download_count_hash["epub"]
      )
  else
    partner_story_downloads_obj.low_res_pdf_downloads = download_count_hash["low_res_pdf"]
    partner_story_downloads_obj.high_res_pdf_downloads = download_count_hash["high_res_pdf"]
    partner_story_downloads_obj.epub_downloads = download_count_hash["epub"]
    partner_story_downloads_obj.total_downloads = download_count_hash["low_res_pdf"] + download_count_hash["high_res_pdf"] + download_count_hash["epub"]
  end
  partner_story_downloads_obj.save!
end

puts "Calling API to get view count for all SW illustrations"
api_response = RestClient.get "#{partner_url}/api/v0/analytics/illustration_view_count?token=#{token}&platform_code=#{platform_code}"
api_data = JSON.parse(api_response)
api_data.each do |illustration_uuid, view_count|
  partner_illustration_views_obj = PartnerIllustrationViews.where(:organization_id => organization_id).where(:illustration_uuid => illustration_uuid).first
  if partner_illustration_views_obj == nil
    partner_illustration_views_obj = PartnerIllustrationViews.new(:organization_id => organization_id, :illustration_uuid => illustration_uuid, :views => view_count)
  else
    partner_illustration_views_obj.views = view_count
  end
  partner_illustration_views_obj.save!
end

puts "Calling API to get download count for all SW illustrations"
api_response = RestClient.get "#{partner_url}/api/v0/analytics/illustration_download_count?token=#{token}&platform_code=#{platform_code}"
api_data = JSON.parse(api_response)
api_data.each do |illustration_uuid, download_count|
  partner_illustration_downloads_obj = PartnerIllustrationDownloads.where(:organization_id => organization_id).where(:illustration_uuid => illustration_uuid).first
  if partner_illustration_downloads_obj == nil
    partner_illustration_downloads_obj = PartnerIllustrationDownloads.new(:organization_id => organization_id, :illustration_uuid => illustration_uuid, :downloads => download_count)
  else
    partner_illustration_downloads_obj.downloads = download_count
  end
  partner_illustration_downloads_obj.save!
end