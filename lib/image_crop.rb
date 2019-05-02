module ImageCrop

  def get_scaled_dimensions( frame_dimensions, image_dimensions )  
   image_w, image_h = image_dimensions
   frame_w, frame_h = frame_dimensions 
   ratio_image = image_w / image_h

   derived_h = frame_w / ratio_image
   if derived_h > frame_h
     difference_h = derived_h - frame_h
     frame_w = frame_w - difference_h * ratio_image
   end
   [frame_w, frame_w / ratio_image]
  end

  def get_image_dimensions(page)
    illustration_dimension = page.illustration_crop.illustration.image_geometry(:original_for_web)
    illustration_width = illustration_dimension.width
    illustration_height = illustration_dimension.height
    crop_details = page.illustration_crop.parsed_crop_details 

    if page.image_type == "image/gif"
      crop_details['crop_x'] ||= 805
      crop_details['crop_y'] ||= 432.75 
      width, height = get_scaled_dimensions([crop_details['crop_x'], crop_details['crop_y']], [illustration_width, illustration_height])
      left = (width - crop_details['crop_x']) / 2
      top = (height - crop_details['crop_y'] ) / 2


      left = (left * 100 / crop_details['crop_x']).round(3) rescue nil
      top = (top * 100 / crop_details['crop_y']).round(3) rescue nil
      width = (width * 100 / crop_details['crop_x']).round(3)
      height = (height * 100 / crop_details['crop_y']).round(3)
    else
      left =  (crop_details["x"]/crop_details["ratio_x"] rescue 0)
      top  =  (crop_details["y"]/crop_details["ratio_y"] rescue 0)
      height = (illustration_height/crop_details["ratio_y"] rescue 0)
      height = default_height(page, illustration_height) if height == 0
      width = (illustration_width/crop_details["ratio_x"] rescue 0)
      width = default_width(page, illustration_width) if width == 0
    end


    [left, top, width, height]
  end


  def get_image_dimensions_unit(page, crop_ratio = 1)
    dimensions = get_image_dimensions(page)
    unit = "%"

    if page.image_type != "image/gif"
      unit = "px"
      dimensions = dimensions.map {|dimen| dimen / crop_ratio}
    end

    dimensions.push(unit)
  end


end
