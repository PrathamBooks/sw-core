  ['People', 'Nature & Weather', 'Buildings', 'Animals & Birds', 'Objects', 'Food & Culture', 'Transport', 'Backdrop'].each {|ic|
    IllustrationCategory.create!(name: ic)
  }

  ['Watercolour', 'Digital art', 'Pencil sketches', 'Collage', 'Realistic', 'Cartoony', 'Black and white', 'Photographs', 'Folk art', 'Detailed'].each { |is|
    IllustrationStyle.create!(name: is)
  }

  ['History and Culture', 'Writing Prompts', 'Wordless Stories', 'STEM', 'Read Aloud', 'My World', 'Lifeskills',
    'Inspiring Stories', 'Environment', 'Humor', 'Language and Grammar'].each { |lc| ListCategory.create!(name: lc)
  }

  {
    'Assamese'  => 'bengali',
    'Bengali'   => 'bengali',
    'Gujarati'  => 'gujrati',
    'Hindi'     => 'devanagri',
    'Kannada'   => 'kannada',
    'Malayalam' => 'malayalam',
    'Marathi'   => 'devanagri',
    'Nepali'    => 'devanagri',
    'Odia'     => 'odia',
    'Punjabi'   => 'punjabi',
    'Sanskrit'  => 'devanagri',
    'Tamil'     => 'tamil',
    'Telugu'    => 'telugu',
    'Spanish'   => 'spanish',
    'French'    => 'french'
  }.each { |k,v| language = Language.create!(name: k, translated_name: k, can_transliterate: true, script: v)
  }
  #Globalize gem is translating the translated_name attribute into a nested attributes and creating new record for language_translations

  Language.create!(name: 'English',translated_name: "English", can_transliterate: false, script: 'english')
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
    'Telugu'    =>  'te',
    'Spanish'   => 'es',
    'French'    => 'fr'
  }
  locale_mapping.each do |name,locale|
    Language.find_by_name(name).update(locale: locale)
  end

  fonts = {
  "english"        => "Noto Sans",
  "isizulu"        => "Noto Sans",
  "kiswahili"      => "Noto Sans",
  "spanish"        => "Noto Sans",
  "french"         => "Noto Sans",
  "odia"           => "Noto Sans Oriya",
  "juanga"         => "Noto Sans Oriya",
  "munda"          => "Noto Sans Oriya",
  "kui"            => "Noto Sans Oriya",
  "saura"          => "Noto Sans Oriya",
  "bengali"        => "Noto Sans Bengali",
  "assamese"       => "Noto Sans Bengali",
  "manipuri"       => "Noto Sans Bengali",
  "gujrati"        => "Noto Sans Gujarati",
  "devanagri"      => "Noto Sans Devanagari",
  "konkani"        => "Noto Sans Devanagari",
  "sanskrit"       => "Noto Sans Devanagari",
  "sindhi"         => "Noto Sans Devanagari",
  "marathi"        => "Noto Sans Devanagari",
  "maithili"       => "Noto Sans Devanagari",
  "bodo"           => "Noto Sans Devanagari",
  "nepali"         => "Noto Sans Devanagari",
  "kannada"        => "Noto Sans Kannada",
  "tulu"           => "Noto Sans Kannada",
  "malayalam"      => "Noto Sans Malayalam",
  "punjabi"        => "Noto Sans Gurmukhi",
  "tamil"          => "Noto Sans Tamil",
  "telugu"         => "Noto Sans Telugu",
  "tibetan"        => "Noto Sans Tibetan",
  "korean"         => "Noto Sans KR",
  "khmer"          => "Noto Serif Khmer",
  "japanese"       => "Noto Sans JP",
  "urdu"           => "Noto Nastaliq Urdu",
  "burmese"        => "Noto Sans Myanmar",
  "hebrew"         => "Noto Sans Hebrew",
  "arabic"         => "Noto Naskh Arabic",
  "kurdish_arabic" => "Noto Naskh Arabic",
  "sinhalese"      => "Noto Sans Sinhala",
  "thai"           => "Noto Sans Thai"
}

fonts.each do |key,val|
  LanguageFont.create(:script => key, :font => val)
end

Language.all.each do |lang|
  lang.language_font_id = LanguageFont.find_by_script(lang.script).id
  lang.save!
end

  ['Fiction', 'Non-fiction', 'Folktales & Myths', 'Fantasy', 'Adventure & Mystery', 'Animal Stories', 'Family & Friends', 'Funny', 'Scary', 'Poems', 'Plays', 'Biographies', 'Science & Nature', 'Math', 'History', 'Place & Culture', 'Series', 'Award-winning', 'Read-Aloud Stories', 'Lifeskills', 'Activity Books', 'Audio Books'].each { |sc|
    StoryCategory.create!(name: sc)
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

  Organization.create!(organization_name: 'Test organization', organization_type: "Publisher", country: "India", city: nil, number_of_classrooms: 10, children_impacted: 10, status: "Approved", email: "test_org@gmail.com")
