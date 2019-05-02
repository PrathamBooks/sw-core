require 'builder'

namespace :seo do
  SITE_URL = "https://storyweaver.org.in"
  STORY_URL = SITE_URL + "/stories/"
  IMAGE_URL = SITE_URL + "/illustrations/"
  LIST_URL = SITE_URL + "/lists/"
  STATIC_URLS_LIST =  [ "/", "/stories", "/translate", "/illustrations", "/lists",
    "/about", "/story_weaver_and_you", "/campaign", "/our_supporters", "/volunteer", 
    "/prathambooks", "/open_content", "/tutorials", "/uploading_an_illustration", "/writing_a_story", "/translation_tools_and_tips",
    "/dos_and_donts", "/reading_levels", "/terms_and_conditions", "/privacy_policy", "/disclaimer", "/press", "/picture_gallery",
    "/contact", "/careers", "/feedback_and_comments", "/faqs", "/past_campaigns", "/weave_a_story_campaign", "/wonder_why_week",
    "/freedom_to_read", "/blog", "/phonestories", "/phonestories/watchout" ]

  desc "Generate sitemap.xml file, place it inside public folder, Run periodically using cronjob"
  task generate_sitemap: :environment do
    include ApplicationHelper

    xml_file = File.new("#{Rails.root}/public/sitemap.xml", "wb")
    xml = Builder::XmlMarkup.new(indent: 2, target: xml_file) 
    xml.instruct! :xml, :encoding => "UTF-8"
    
    all_published_stories = Story.where(status: Story.statuses[:published])
    all_published_images = Illustration.where("image_mode = ? and is_pulled_down = ?", false, false)
    all_published_lists = List.where(status:1)

    xml.urlset(xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9",
     :"xmlns:image" => "http://www.google.com/schemas/sitemap-image/1.1",
     :"xmlns:xhtml" => "http://www.w3.org/1999/xhtml")  do
      
      STATIC_URLS_LIST.each do |link| 
        xml.url do |p|
          p.loc SITE_URL + link
          p.changefreq "monthly"
          p.priority 0.8
        end
      end
      
      all_published_stories.each do |story|
        xml.url do |p|
          p.loc STORY_URL + story_slug(story)
          p.lastmod story.updated_at.to_date
         
          alt_stories = []

          if story.is_root?
            p.priority 0.8
            alt_stories = story.descendants.published.translated
          elsif story.derivation_type == "translated"
            alt_stories << story.root if story.root.status == "published"
            alt_stories << story.root.descendants.published.translated.where.not(id: story.id)
            alt_stories.flatten!
          end

          if get_cover_image_url(story).present?
            xml.tag!('image:image') do 
              xml.image :loc, get_cover_image_url(story)
              xml.image :title, escape_special_characters(story.title)
              xml.image :caption, escape_special_characters(story.synopsis)
            end
          end
	  
          alt_stories.each do |alt_story|
            xml.tag!( 'xhtml:link',
                      {:"rel" => "alternate"},
                      {:"hreflang" => alt_story.language.locale },
                      {:"href" => STORY_URL + story_slug(alt_story)} )
          end

        end
      end

      all_published_images.each do |image|
        xml.url do
          xml.loc IMAGE_URL + illustration_slug(image)
          xml.lastmod image.updated_at.to_date
          xml.tag!('image:image') do 
            xml.image :loc, get_image_url(image)
            xml.image :title, escape_special_characters(image.name)
          end
        end
      end

      all_published_lists.each do |list|
        xml.url do |p|
          p.loc LIST_URL + list_slug(list)
          p.changefreq "weekly"
          p.lastmod list.updated_at.to_date
          p.priority 0.8
        end
      end

    end
    xml_file.close
  end
end
