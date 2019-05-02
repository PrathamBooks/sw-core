namespace :languages do
  desc "Initialize level band paths"
  task add_level_bands: :environment do
  languages_lb = {
    "Assamese" =>    "Assamese",
    "Ateso"   =>      "Ateso",
    "Bengali"   =>     "Bengali",
    "Dhopadhola" =>    "Dhopadhola",
    "English"   =>   "English",
    "Gujarati"  =>    "Gujarati",
    "Hindi"      =>   "Hindi",
    "Kannada"    =>   "Kannada",
    "Kinyarwanda" =>   "Kinyarwanda",
    "Kumam"     => "Kumam",
    "Luganda"    =>    "Luganda",
    "Lumasaaba"  =>   "Lumasaaba",
    "Lusoga"     =>  "Lusoga",
    "Marathi"    =>  "Marathi",
    "Odia"     =>  "Odiya",
    "Punjabi"    =>    "Punjabi",
    "Runyankore" =>   "Runyankore",
    "Runyoro / Runyakitara" =>  "Runyoro_Runyakitara",
    "Tamil"    =>      "Tamil",
    "Telugu"    =>     "Telugu",
    "Turkish"    =>    "Turkish",
    "Urdu"        =>   "Urdu"
    }
    languages_lb.each do |k,v|
      if(Language.where(:name=>k).any?)
        l = Language.where(:name => k)[0]
        l.level_band = v
        l.save!
      end
    end    
  end

end
