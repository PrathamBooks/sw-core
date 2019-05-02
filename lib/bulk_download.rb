module BulkDownload

  # send_data used in this function is a ActionController method, 
  # will work only when included and called from inside a Rails controller
  
  def bk_download params, current_user, request
    filename = get_download_name(params)
    # NTFS file system don't support following empty space, /, \, *, ?, <, >, |, ", :
    # Replace filename of not suported special characters with -
    filename = filename.gsub(/[\x00\/\\:\*\?\"<>\|]/, '-')

    temp_file = Tempfile.new(filename)
    path = Rails.root.join('tmp_bulk')
    list = params[:list_id].present? ? List.find(params[:list_id]) : nil

    Zip::File.open(temp_file.path, Zip::File::CREATE) do |zipfile|
      params.each do |story_format, stories|
        stories[:stories_to_download].each do|story_id|
          story = Story.find(story_id)
          story_revision = story.revision.nil? ? '' : ('_'+(story.revision).to_s)
          if Rails.env.production?
            head(:not_found) and return if story.nil?
            directory = fog_directory
            if story_format == "ePub"
              url = directory.files.get("stories/#{story.id}/epub/#{story.to_param}#{story_revision}.epub").public_url
              Rails.logger.info url
              #story.update_downloads_count("epub", current_user, request.remote_ip,falg=true)
            elsif story_format == "HiRes PDF" || story_format == "PDF"
              url =  directory.files.get("stories/#{story.id}/pdfs/#{stories[:high_resolution] == "true" ? "high" : "low"}/#{story.to_param}#{story_revision}.pdf").public_url
              Rails.logger.info url
              #story.update_downloads_count(params[:high_resolution] == "true" ? "high" : "low", current_user, request.remote_ip,falg=true)
            elsif story_format == "images_only"
              #story.update_downloads_count("images_only", current_user, request.remote_ip,falg=true)
              get_images(story, zipfile,path)
            elsif story_format == "Text Only"
              #story.update_downloads_count("text_only", current_user, request.remote_ip,falg=true)
              get_text(story,zipfile,path)
            end
            #get_attribution_text(story, zipfile, path)
            if story_format == "ePub" || story_format == "PDF" || story_format == "HiRes PDF"
              system("wget -P #{path} #{url}")
              s_format = (story_format == "ePub" ? "epub" : "pdf")
              zipfile.add("#{story.to_param}."+s_format, "#{path}/#{story.to_param}#{story_revision}."+s_format)
            end
          elsif Rails.env.development? || Rails.env.test?
            head(:not_found) and return if story.nil?
            if story_format == "ePub"
              url =  Rails.env.development? ? "#{Rails.root.to_s}/public/system/story-weaver/stories/#{story.id}/epub" : "#{Rails.root.to_s}/public/spec/test_files/stories/#{story.id}/epub"
            elsif story_format == "PDF"
              url = Rails.env.development? ? "#{Rails.root.to_s}/public/system/story-weaver/stories/#{story.id}/pdfs/#{stories[:high_resolution] == "true" ? "high" : "low"}" : "#{Rails.root.to_s}/public/spec/test_files/stories/#{story.id}/pdfs/#{stories[:high_resolution] == "true" ? "high" : "low"}"
            elsif story_format == "HiRes PDF"
              url = Rails.env.development? ? "#{Rails.root.to_s}/public/system/story-weaver/stories/#{story.id}/pdfs/#{stories[:high_resolution] == "true" ? "high" : "low"}" : "#{Rails.root.to_s}/public/spec/test_files/stories/#{story.id}/pdfs/#{stories[:high_resolution] == "true" ? "high" : "low"}"
            elsif story_format == "images_only"
              get_images(story, zipfile,path)
            elsif story_format == "text_only"
              get_text(story,zipfile,path)
            end
            #get_attribution_text(story, zipfile, path)
            if story_format == "ePub" || story_format == "PDF" || story_format == "HiRes PDF"
              s_format = (story_format == "ePub" ? "epub" : "pdf")
              zipfile.add("#{story.to_param}."+s_format, url + '/' + "#{story.to_param}#{story_revision}."+s_format)
            end
          end
        end
      end

      # Add usage document if it is a list download
      if list.present? && params[:format] == "pdf"
          add_usage_doc(list.id, zipfile, path)
          list.track_download(current_user, request.remote_ip)
      end
    end
    params.each do |story_format, stories|
      download_type = (story_format == "PDF" || story_format == "HiRes PDF" ? stories[:high_resolution] == "true" ? "high" : "low" : story_format)
      update_bulk_download_count(stories[:stories_to_download],download_type,current_user, request.remote_ip,falg=true, list)
    end

    zip_data = File.read(temp_file.path)
    send_data(zip_data, :dispostion=>'inline', :stream => true, :filename => filename)
    temp_file.close
    temp_file.unlink
    FileUtils.rm_rf("#{path}") if File.exist?("#{path}")
  end

  def get_download_name params
    filename = 'bulk_download.zip'

    if params[:list_name].present?
      resolution = params[:high_resolution] == 'true'? '-high':'-low'
      resolution = "" if params[:format] != "pdf"
      filename = "#{params[:list_name]}-#{params[:format]}#{resolution}.zip"
    end
    
    return filename
  end

  def get_images(story,zipfile,path)
    illustration_array = []
    story.pages.each do|page|
      if page.illustration_crop.present?
        file_name = page.illustration_crop.image.original_filename
        if Rails.env.production?
          illustration_array.push(page.illustration_crop.illustration)
          url = page.illustration_crop.image.url.split("?").first
          system("wget -P #{path} #{url}")
          zipfile.add("#{story.to_param}/#{file_name}", "#{path}/#{file_name}")
        elsif Rails.env.development?
          illustration_array.push(page.illustration_crop.illustration)
          url = "#{Rails.root.to_s}/public/system/story-weaver/illustration_crops/#{page.illustration_crop.id}/original/#{file_name}"
          zipfile.add("#{story.to_param}/#{file_name}", "#{url}")
        else
          illustration_array.push(page.illustration_crop.illustration)
          url = "#{Rails.root.to_s}/public/spec/test_files/illustration_crops/#{page.illustration_crop.id}/original/#{file_name}"
          zipfile.add("#{story.to_param}/#{file_name}", "#{url}")
        end
      end
    end
    illustration_array.uniq.each do|illustration|
      illustration.update_downloads(current_user, request.remote_ip, "original")
    end
  end

  def add_usage_doc(list_id, zipfile, path)
    usage_doc = path.join("usage_doc.txt")
    FileUtils.mkdir_p(File.dirname(usage_doc))
    list = List.find(list_id)
    File.open(usage_doc, "w+")  do |f|
      f.puts "Name: #{list.title}"
      f.puts "Description: #{list.description}"
      f.puts "____________________________________________________"
      f.puts
      f.puts "Below are the books which are part of this list,"
      f.puts

      list.stories.each_with_index do |story, index| 
        f.puts "#{index + 1}. #{story.title}"
        how_to_use = ListsStory.where("list_id = ? and story_id = ?", list.id, story.id).first.how_to_use
        synopsis = story.synopsis
        f.puts "How to Use/Synopsis: #{how_to_use || synopsis}"
        f.puts "\n"
      end
    end

    zipfile.add("Tips to use this list.doc", usage_doc)
  end

  def get_text(story,zipfile,path)
    filename = path.join("#{story.to_param}.txt")
    FileUtils.mkdir_p(File.dirname(filename))
    File.open(filename, "w+")  do |f|
      f.puts "\n"
      f.puts "Cover:"
      f.puts "\n"
      f.puts "Title: #{story.title}"
      if story.is_translation?
        f.puts "Written by: #{story.root.authors.collect(&:name).join(",")}"
        f.puts "Translated by: #{story.authors.collect(&:name).join(",")}"
      else
        f.puts "Written by: #{story.authors.collect(&:name).join(",")}"
      end
      f.puts "Illustrated by: #{story.illustrators.collect(&:name).join(",")}"
      story.story_pages.each_with_index do |p, index|
        f.puts "\n"
        f.puts "Page: #{index + 2}" if p.content
        f.puts "\n"
        if p.content
          cleaned_content = p.content.gsub("&nbsp;", " ").gsub("\n", " ")
          cleaned_content = cleaned_content.gsub("</p>", "\n") #add newlines at paragraphs
          # remove html tags
          cleaned_content = ActionView::Base.full_sanitizer.sanitize(CGI.unescapeHTML(cleaned_content))
          # above may leave empty spaces before and after newlines, remove them
          cleaned_content = cleaned_content.gsub(/\s*\n\s*/, "\n")
          # replace multiple newlines with one, and remove new line from beginning
          cleaned_content = cleaned_content.squeeze("\n ").gsub(/^\n/,'')
          f.puts cleaned_content
        end
      end
      f.puts "\n"
      f.puts "Inner Back Cover:"
      f.puts "\n"
      f.puts "Blurb: #{story.synopsis}"
    end
    zipfile.add("#{story.to_param}.txt", filename)
  end

  def get_attribution_text(story,zipfile,path)
    filename = path.join("#{story.to_param}_attribution.txt")
    FileUtils.mkdir_p(File.dirname(filename))
    File.open(filename, "w+")  do |f|
      f.puts "\n"
      f.puts "Title: #{story.title}"
      f.puts "\n"
      attribution_text = story.attribution_text_for_downloaded_stories
      cleaned_content = attribution_text.gsub("&nbsp;", " ").gsub("\n", " ")
      cleaned_content = cleaned_content.gsub("</attribution_text>", "\n") #add newlines at paragraphs
      # remove html tags
      cleaned_content = ActionView::Base.full_sanitizer.sanitize(CGI.unescapeHTML(cleaned_content))
      # above may leave empty spaces before and after newlines, remove them
      cleaned_content = cleaned_content.gsub(/\s*\n\s*/, "\n")
      # replace multiple newlines with one, and remove new line from beginning
      cleaned_content = cleaned_content.squeeze("\n ").gsub(/^\n/,'')
      f.puts "Attribution Text: #{cleaned_content}"
    end
    zipfile.add("#{story.to_param}_attribution.txt", filename)
  end


  def update_bulk_download_count(stories,download_type,current_user, ip_address,flag, list)
    download = StoryDownload.new
    download.user = current_user
    download.download_type = download_type
    download.story_id = 0
    download.ip_address = ip_address
    download.organization_user = flag ? (current_user.organization.present? ? true : false) : false
    download.list_id = list.id if list.present?
    download.save!
    current_user.update_attribute(:story_download_count, (current_user.story_download_count + stories.count))
    update_stories_downloads(stories,download,download_type)
  end


  def update_stories_downloads(stories_list,download,type)
    stories_list.each do|story|
      story = Story.find(story)
      download.stories << story
      if type == "epub"
        story.update_attribute(:epub_downloads, story.epub_downloads+1)
      elsif type == "low"
        story.update_attribute(:downloads, story.downloads+1)
      elsif type == "high"
        story.update_attribute(:high_resolution_downloads, story.high_resolution_downloads+1)
      elsif type == "images_only"
        story.update_attribute(:images_only, story.images_only+1)
      elsif type == "text_only"
        story.update_attribute(:text_only, story.text_only+1)
      end
    end
  end

  #Get google cloud storage bucket using fog
  def fog_directory
    credentials =  YAML.load_file("#{Rails.root}/config/fog.yml")
    connection = Fog::Storage.new(credentials.values.first.symbolize_keys!)
    directory = connection.directories.get(Settings.fog.directory)
  end
end
