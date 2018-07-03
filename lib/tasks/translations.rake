namespace :db do
  desc "Create translations"
  task :create_translations => :environment do
    csv_text = File.read("#{Rails.root}/translations.csv")
    csv = CSV.parse(csv_text, :headers => true)
    translate = nil;
    translate_type = nil;
    csv.each_with_index do |row, index|
      translate = row[0].try(:strip) if row[0].present?
      if translate == "Category"
        translate_type = StoryCategory.find_by_name(row[1].try(:strip))
      elsif translate == "Language"
        translate_type = Language.find_by_name(row[1].try(:strip))
       elsif translate == "Styles"
        translate_type = IllustrationStyle.find_by_name(row[1].try(:strip))
      elsif translate == "Illustration_categories"
        translate_type = IllustrationCategory.find_by_name(row[1].try(:strip)) 
      end
      if translate_type
        translate_type.translated_name = row[1].try(:strip)
        translate_type.save!
        translation = translate_type.translations.new
        translation.locale = "hi"
        translation.name = row[1].try(:strip)
        translation.translated_name = row[2].try(:strip)
        translation.save!
      end
    end
  end
end