unless Rails.env == 'test' || IllustrationCategory.count > 0
  ['People', 'Nature & Weather', 'Buildings', 'Animals & Birds', 'Objects', 'Food & Culture', 'Transport', 'Backdrop'].each {|ic|
    IllustrationCategory.create!(name: ic, translated_name: ic)
  }

  ['Watercolour', 'Digital art', 'Pencil sketches', 'Collage', 'Realistic', 'Cartoony', 'Black and white', 'Photographs', 'Folk art', 'Detailed'].each { |is|
    IllustrationStyle.create!(name: is, translated_name: is)
  }

  lf = LanguageFont.create!(font: "Noto Sans", script: "english")
  Language.create!(name: 'English', can_transliterate: false, script: 'english', language_font: lf, translated_name: 'English')

  lf = LanguageFont.create!(font: "Noto Sans", script: "english")
  Language.create!(name: 'German', can_transliterate: false, script: 'english', language_font: lf, translated_name: 'German')

  locale_mapping = {
    'Assamese'  =>  'as',
    'Bengali'   =>  'bn',
    'Gujarati'  =>  'gu',
    'Hindi'     =>  'hi',
    'Kannada'   =>  'kn',
    'English'   =>  'en',
    'Malayalam' =>  'ml',
    'Marathi'   =>  'mr',
    'Nepali'    =>  'en',
    'Odia'     =>  'or',
    'Punjabi'   =>  'pa',
    'Sanskrit'  =>  'en',
    'Tamil'     =>  'ta',
    'Telugu'    =>  'te'
  }
  locale_mapping.each do |name,locale|
    Language.where(name: name).update_all(locale: locale)
  end

  ['Fiction', 'Non-fiction', 'Folktales & Myths', 'Fantasy', 'Adventure & Mystery', 'Animal Stories', 'Family & Friends', 'Funny', 'Scary', 'Poems', 'Plays', 'Biographies', 'Science & Nature', 'Math', 'History', 'Place & Culture', 'Series', 'Award-winning', 'Read-Aloud Stories', 'Lifeskills', 'Activity Books', 'Audio Books'].each { |sc|
    StoryCategory.create!(name: sc, translated_name: sc)
  }

  StoryPageTemplate.create!(name: 'sp_h_iL50_cR50', default: true, orientation: 'landscape', image_position: 'left',content_position: 'right', image_dimension: 50, content_dimension: 50)
  StoryPageTemplate.create!(name: 'sp_h_iT66_cB33', orientation: 'landscape', image_position: 'top',content_position: 'bottom', image_dimension: 66.67, content_dimension: 33.33)
  StoryPageTemplate.create!(name: 'sp_h_iL66_cR33', orientation: 'landscape', image_position: 'left',content_position: 'right', image_dimension: 66.67, content_dimension: 33.33)
  StoryPageTemplate.create!(name: 'sp_h_iT75_cB25', orientation: 'landscape', image_position: 'top',content_position: 'bottom', image_dimension: 75, content_dimension: 25)
  StoryPageTemplate.create!(name: 'sp_h_i100',      orientation: 'landscape', image_position: 'fill',content_position: 'nil', image_dimension: 100, content_dimension: 0)
  StoryPageTemplate.create!(name: 'sp_h_c100',      orientation: 'landscape', image_position: 'nil',content_position: 'fill', image_dimension: 0, content_dimension: 100)
  StoryPageTemplate.create!(name: 'sp_h_iB66_cT33', orientation: 'landscape', image_position: 'bottom',content_position: 'top', image_dimension: 66.67, content_dimension: 33.33)
  StoryPageTemplate.create!(name: 'sp_h_text_overlay',orientation: 'landscape', image_position: 'background', content_position: 'foreground', image_dimension: 100, content_dimension: 76)
  StoryPageTemplate.create!(name: 'sp_h_text_overlay1',orientation: 'landscape', image_position: 'background', content_position: 'foreground', image_dimension: 100, content_dimension: 80)

  # DEPRECATED StoryPageTemplate.create!(name: 'sp_h_iR66_cL33', orientation: 'landscape', image_position: 'right',content_position: 'left', image_dimension: 66.67, content_dimension: 33.33)
  # DEPRECATED StoryPageTemplate.create!(name: 'sp_h_iR50_cL50', orientation: 'landscape', image_position: 'right',content_position: 'left', image_dimension: 50, content_dimension: 50)
  # DEPRECATED StoryPageTemplate.create!(name: 'sp_h_iB33_cT66', orientation: 'landscape', image_position: 'bottom',content_position: 'top', image_dimension: 33.33, content_dimension: 66.67)
  # DEPRECATED StoryPageTemplate.create!(name: 'sp_h_iB75_cT25', orientation: 'landscape', image_position: 'bottom',content_position: 'top', image_dimension: 75, content_dimension: 25)
  # DEPRECATED StoryPageTemplate.create!(name: 'sp_h_c100',      orientation: 'landscape', image_position: 'top',content_position: 'bottom', image_dimension: 0, content_dimension: 100)
  # DEPRECATED StoryPageTemplate.create!(name: 'sp_v_iB50_cT50', orientation: 'portrait', image_position: 'bottom',content_position: 'top', image_dimension: 50, content_dimension: 50)

  StoryPageTemplate.create!(name: 'sp_v_iT50_cB50', default: true, orientation: 'portrait', image_position: 'top',content_position: 'bottom', image_dimension: 50, content_dimension: 50)
  StoryPageTemplate.create!(name: 'sp_v_iB66_cT33', orientation: 'portrait', image_position: 'bottom',content_position: 'top', image_dimension: 66.67, content_dimension: 33.33)
  StoryPageTemplate.create!(name: 'sp_v_iT66_cB33', orientation: 'portrait', image_position: 'top',content_position: 'bottom', image_dimension: 66.67, content_dimension: 33.33)
  StoryPageTemplate.create!(name: 'sp_v_i100',      orientation: 'portrait', image_position: 'fill',content_position: 'nil', image_dimension: 100, content_dimension: 0)
  StoryPageTemplate.create!(name: 'sp_v_c100',      orientation: 'portrait', image_position: 'nil',content_position: 'fill', image_dimension: 0, content_dimension: 100)
  StoryPageTemplate.create!(name: 'sp_v_iT75_cB25', orientation: 'portrait', image_position: 'top',content_position: 'bottom', image_dimension: 75, content_dimension: 25)

  FrontCoverPageTemplate.create!(name: 'fc_h_iT50_cB50', orientation: 'landscape', image_position: 'top', content_position: 'bottom', image_dimension: 50, content_dimension: 50)
  FrontCoverPageTemplate.create!(name: 'fc_h_iT66_cB33', default: true, orientation: 'landscape', image_position: 'top', content_position: 'bottom', image_dimension: 66.67, content_dimension: 33.33)
  FrontCoverPageTemplate.create!(name: 'fc_v_iT50_cB50', orientation: 'portrait', image_position: 'top',  content_position: 'bottom', image_dimension: 50, content_dimension: 50)
  FrontCoverPageTemplate.create!(name: 'fc_v_iT66_cB33', default: true, orientation: 'portrait', image_position: 'top', content_position: 'bottom', image_dimension: 66.67, content_dimension: 33.33)

  BackCoverPageTemplate.create!(name: 'bc_h_c100', default: true, orientation: 'landscape', image_position: 'nil', content_position: 'fill', image_dimension: 0, content_dimension: 100)
  BackCoverPageTemplate.create!(name: 'bc_v_c100', default: true, orientation: 'portrait', image_position: 'nil', content_position: 'fill', image_dimension: 0, content_dimension: 100)

  BackInnerCoverPageTemplate.create!(name: 'bic_h_c100', default: true, orientation: 'landscape', image_position: 'nil', content_position: 'fill', image_dimension: 0, content_dimension: 100)
  BackInnerCoverPageTemplate.create!(name: 'bic_v_c100', default: true, orientation: 'portrait', image_position: 'nil', content_position: 'fill', image_dimension: 0, content_dimension: 100)

  DedicationPageTemplate.create!(name: 'dd_h_c100', default: true, orientation: 'landscape', image_position: 'nil', content_position: 'fill', image_dimension: 0, content_dimension: 100)
  DedicationPageTemplate.create!(name: 'dd_v_c100', default: true, orientation: 'portrait', image_position: 'nil', content_position: 'fill', image_dimension: 0, content_dimension: 100)
end
