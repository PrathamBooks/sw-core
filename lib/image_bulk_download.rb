module ImageBulkDownload

  # send_data used in this function is a ActionController method, 
  # will work only when included and called from inside a Rails controller
  
  def image_bk_download params, current_user, request
    filename = get_images_download_name
    # NTFS file system don't support following empty space, /, \, *, ?, <, >, |, ", :
    # Replace filename of not suported special characters with -
    filename = filename.gsub(/[\x00\/\\:\*\?\"<>\|]/, '-')

    temp_file = Tempfile.new(filename)
    path = Rails.root.join('tmp_bulk')

    Zip::File.open(temp_file.path, Zip::File::CREATE) do |zipfile|
      params.each do |image_format, images|
        images[:images_to_download].each do|illustration_id|
          illustration = Illustration.find(illustration_id)
          if Rails.env.production?
            content_type = illustration.image.content_type
            head(:not_found) and return if illustration.nil?
            if image_format == "JPEG" || image_format == "HiRes JPEG"
              url = illustration.image.url(images[:style])
              Rails.logger.info url
            end
            system("wget -P #{path} #{url}")
            change_image_name = url.split("/").last
            extname = change_image_name.split(".")[1].split("?")[0]
            system("mv #{path}/#{change_image_name} #{path}/#{illustration.to_param}.#{extname}")
            zipfile.add("#{illustration.to_param}.#{extname}", "#{path}/#{illustration.to_param}.#{extname}")
            #get_attribution_text(illustration, zipfile, path)
          elsif Rails.env.development? || Rails.env.test?
            head(:not_found) and return if illustration.nil?
            extname = File.extname(illustration.image.to_s)[1..-1].split("?").first
            if image_format == "JPEG" || image_format == "HiRes JPEG"
              url = "#{Rails.root.to_s}/#{illustration.image.path(images[:style])}"
            end
            zipfile.add("#{illustration.to_param}.#{extname}", "#{url}")
            #get_attribution_text(illustration, zipfile, path)
          end
        end
      end
    end
    params.each do |image_format, images|
      update_bulk_download_count_images(images[:images_to_download],image_format,current_user, request.remote_ip,falg=true)
    end
    zip_data = File.read(temp_file.path)
    send_data(zip_data, :dispostion=>'inline', :stream => true, :filename => filename)
    temp_file.close
    temp_file.unlink
    FileUtils.rm_rf("#{path}") if File.exist?("#{path}")
  end

  def get_images_download_name
    filename = 'image_bulk_download.zip'
    return filename
  end

  def get_attribution_text(illustration, zipfile, path)
    filename = path.join("#{illustration.to_param}_attribution.txt")
    FileUtils.mkdir_p(File.dirname(filename))
    File.open(filename, "w+")  do |f|
      f.puts "\n"
      f.puts "Title: #{illustration.name}"
      f.puts "\n"
      attribution_text = illustration.attribution_text_for_downloaded_illustrations
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
    zipfile.add("#{illustration.to_param}_attribution.txt", filename)
  end

  def update_bulk_download_count_images(illustration_ids,download_type,current_user, ip_address,flag)
    download = IllustrationDownload.new
    download.user = current_user
    download.download_type = download_type
    download.illustration_id = 0
    download.ip_address = ip_address
    download.organization_user = flag ? (current_user.organization.present? ? true : false) : false
    download.save!
    current_user.update_attribute(:illustration_download_count, (current_user.illustration_download_count + illustration_ids.count))
    illustration_ids.each do|image|
      illustration = Illustration.find(image)
      download.illustrations << illustration
      illustration.reindex
    end
  end

end
