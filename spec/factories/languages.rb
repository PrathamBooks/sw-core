# == Schema Information
#
# Table name: languages
#
#  id                :integer          not null, primary key
#  name              :string(32)       not null
#  is_right_to_left  :boolean          default(FALSE)
#  can_transliterate :boolean          default(FALSE)
#  created_at        :datetime
#  updated_at        :datetime
#  script            :string(255)
#  locale            :string(255)
#  bilingual         :boolean          default(FALSE)
#  language_font_id  :integer
#  level_band        :string(255)
#
# Indexes
#
#  index_languages_on_name  (name)
#

FactoryGirl.define do
  factory :language do
    sequence(:name) { |n| "Language #{n}" }
    sequence(:script) { |n| "script #{n}" }
    is_right_to_left false
    can_transliterate false
    sequence(:translated_name) { |n| "Language #{n}" }
  end

  factory :english, class: Language do
    name "English"
    script "english"
    locale "en"
    is_right_to_left false
    can_transliterate false
    translated_name "English translation"
  end
  
  factory :kannada, class: Language do
    name "Kannada"
    script "kannada"
    locale "kn"
    is_right_to_left false
    can_transliterate false
    translated_name "Kannada translation"
  end
  factory :hindi, class: Language do
    name "Hindi"
    script "hindi"
    locale "hi"
    is_right_to_left false
    can_transliterate false
    translated_name "Hindi translation"
  end
  factory :telugu, class: Language do
    name "Telugu"
    script "telugu"
    locale "te"
    is_right_to_left false
    can_transliterate false
    translated_name "Telugu translation"
  end

end
