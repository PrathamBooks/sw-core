require "imgkit"
require 'utils/utils'

def org_logo(story)
  if story.organization.present?
    story.organization.logo.present? ? story.organization.logo.url(:original) : ''
  else
   Rails.root.join('app', 'assets', 'images', 'publisher_logos/community.jpg')
  end
end

def copy_organization_logo(story, dir)
  extension = File.extname(org_logo(story)).split("?")[0]
  logo_file_name = "#{dir}/publisher_logo#{extension}"
  FileUtils.cp Utils.download_to_file(org_logo(story)), logo_file_name
  return logo_file_name
end

def level_band_loc(story)
  reading_level = story.reading_level
  lb_name = story.language.level_band ?  story.language.level_band : "English"
  return Rails.root + "app/assets/images/level_bands/Level_#{reading_level}_#{lb_name}.png"
end


def copy_level_bands(story, dir)
  level_band_file_name = "#{dir}/level_band.png"
  FileUtils.cp level_band_loc(story), level_band_file_name
  return level_band_file_name
end

def copy_fonts(story, dir)
  storyFont = story.language.language_font.font.gsub(/\s+/, "")
  Dir.mkdir("#{dir}/fonts")

  # Adding NotoSans by default
  Dir.mkdir("#{dir}/fonts/NotoSans")
  Dir.mkdir("#{dir}/fonts/NotoSans/Regular")
  Dir.mkdir("#{dir}/fonts/NotoSans/Bold")
  Dir.mkdir("#{dir}/fonts/NotoSans/Italic")
  Dir.mkdir("#{dir}/fonts/NotoSans/BoldItalic")

  fonts = []

  ['Regular', 'Bold', 'Italic', 'BoldItalic'].each do |style|
    style_path = "#{Rails.root}/app/assets/fonts/NotoSans/#{style}/NotoSans-#{style}_gdi.woff"
    font_file = "#{dir}/fonts/NotoSans/#{style}/NotoSans-#{style}_gdi"
    fonts << "#{font_file.split('/').last(4).join('/')}.woff"
    FileUtils.cp open(style_path), "#{font_file}.woff"
  end
  
  if (['NotoNastaliqUrdu', "NotoSansMongolian", "NotoSansOlChiki"].include? storyFont)
    Dir.mkdir("#{dir}/fonts/#{storyFont}")
    regular_path = "#{Rails.root}/app/assets/fonts/#{storyFont}/#{storyFont}-Regular.woff"
    font_file_regular = "#{dir}/fonts/#{storyFont}/#{storyFont}-Regular"
    fonts << "#{font_file_regular.split('/').last(3).join('/')}.woff"
    FileUtils.cp open(regular_path), "#{font_file_regular}.woff"
  elsif storyFont != "NotoSans"
    Dir.mkdir("#{dir}/fonts/#{storyFont}")
    Dir.mkdir("#{dir}/fonts/#{storyFont}/Regular")
    Dir.mkdir("#{dir}/fonts/#{storyFont}/Bold")
    regular_path = "#{Rails.root}/app/assets/fonts/#{storyFont}/Regular/#{storyFont}-Regular.woff"
    bold_path = "#{Rails.root}/app/assets/fonts/#{storyFont}/Bold/#{storyFont}-Bold.woff"
    font_file_regular = "#{dir}/fonts/#{storyFont}/Regular/#{storyFont}-Regular"
    font_file_bold = "#{dir}/fonts/#{storyFont}/Bold/#{storyFont}-Bold"
    fonts << "#{font_file_regular.split('/').last(4).join('/')}.woff"
    fonts << "#{font_file_bold.split('/').last(4).join('/')}.woff"
    FileUtils.cp open(regular_path), "#{font_file_regular}.woff"
    FileUtils.cp open(bold_path), "#{font_file_bold}.woff"
  end
  fonts
end

def find_cues(html)
  data_cues = html.scan(/span data-cue="(\d+)"/) 
  if data_cues.size > 0
    return data_cues[0][0].to_i, data_cues[-1][0].to_i
  else
    return -1, -1
  end
end

def make_one_page_html(page, story, dir)
  unless page.illustration_crop.nil?
    image_file = "#{dir}/image_#{page.position}"
    FileUtils.cp page.illustration_crop.load_image(:size7), "#{image_file}.jpg"
  end

  templates_dir = "#{Rails.root}/app/views"
  av = ActionView::Base.new(templates_dir)
  av.assign({:page => page})
  extension = File.extname(org_logo(story)).split("?")[0]
  html = av.render(:template => "pages/show.epub.erb", 
                   locals: {
                     :page => page, 
                     :@story => story, 
                     :@additional_illustration_license_types => @additional_illustration_license_types, 
                     :form_authenticity_token => nil,  
                     :@offline_processing => true
                   })
  html.gsub!("<head>", "<head> \n <style type='text/css'> .audio_selected {color:blue !important;} </style>")
  html.gsub!("/images/publisher_logo#{extension}", "publisher_logo#{extension}")
  html.gsub!("/images/level_band.png", "level_band.png")

  min_cue, max_cue = find_cues(html)

  page_image_file_names = []
  crop_w = 0
  crop_h = 0
  if (story.page_orientation == "portrait")
    crop_w = 796
    crop_h = 1200
  else
    crop_w = 1500
    crop_h = 1080
  end

  if min_cue == -1
    page_file_name = "#{dir}/#{page.position}.xhtml"
    f = File.new(page_file_name, 'w')
    f.puts(html)
    f.close()

    if (crop_w > 0)
      kit = IMGKit.new(File.open(page_file_name, "r"), :crop_w => crop_w, :crop_h => crop_h, :width=>1700)
    else
      kit = IMGKit.new(File.open(page_file_name, "r"), :width=>1700)
    end
    page_image_file_name = "#{dir}/#{page.position}.jpg"
    file = kit.to_file(page_image_file_name)
    page_image_file_names << page_image_file_name
  else
    min_cue.upto max_cue do |i|
      page_file_name = "#{dir}/#{page.position}_#{i}.xhtml"
      f = File.new(page_file_name, 'w')
      whtml = html.gsub('data-cue="'+i.to_s+'"', 'class="audio_selected" data-cue="'+i.to_s+'"')
      f.puts(whtml)
      f.close()

      if (crop_w > 0)
        kit = IMGKit.new(File.open(page_file_name, "r"), :crop_w => crop_w, :crop_h => crop_h, :width=>1700)
      else
        kit = IMGKit.new(File.open(page_file_name, "r"), :width=>1700)
      end

      page_image_file_name = "#{dir}/#{page.position}_#{i}.jpg"
      file = kit.to_file(page_image_file_name)
      page_image_file_names << page_image_file_name
    end
  end

  return page_image_file_names
end

# time looks like: 00_00_03-880
def conv_time(str)
  str[0..1].to_i*3600 + str[3..4].to_i*60 + str[6..7].to_i + str[9..11].to_i * 0.001
end

def get_durations(story, directory)
    durations = []
    if Rails.env.production?
      csv_file = directory.files.get("stories/#{story.id}/csv/#{story.to_param}.csv").public_url
      data = open(csv_file)
      data = data.read
    else
      file_path = "#{Rails.root}/public/#{Settings.fog.directory}/stories/#{story.id}/csv/#{story.to_param}.csv"
      data = File.read(file_path)
    end
    word_data = []
    CSV.parse(data) do |row|
      word_data << row
    end
    word_times = []
    word_data[1..-1].each do |row|
      word_times << row[-1]
    end
    0.upto word_times.size-2 do |i|
      durations << conv_time(word_times[i + 1]) - conv_time(word_times[i])
    end
    durations 
end

def create_cfg_file(story_page_files, durations, dir)
  cfg_file_name = "#{dir}/ffmpeg.cfg"
  File.open(cfg_file_name, "w") do |f|
    durations << durations[-1]
    0.upto durations.size-1 do |i|
      f.write "file '#{story_page_files[i]}' \n"
      f.write "duration #{durations[i]} \n"
    end
  end
  cfg_file_name
end

def download_audio_file(story, directory, dir)
    if Rails.env.production?
      audio_file_main = directory.files.get("stories/#{story.id}/audios/story/#{story.to_param}.mp3").public_url
      audio_file_main_name = "#{dir}/audio_main.mp3"
      File.open(audio_file_main_name, "wb") do |f|
        f.write(open(audio_file_main).read)
      end
      audio_file_cover_name = "#{dir}/audio_cover.mp3"
      audio_file_cover = directory.files.get("stories/#{story.id}/audios/cover/#{story.to_param}.mp3").public_url
      File.open(audio_file_cover_name, "wb") do |f|
        f.write(open(audio_file_cover).read)
      end
    else
      audio_file_main_name = "#{Rails.root}/public/#{Settings.fog.directory}/stories/#{story.id}/audios/story/#{story.to_param}.mp3"
      audio_file_cover_name = "#{Rails.root}/public/#{Settings.fog.directory}/stories/#{story.id}/audios/cover/#{story.to_param}.mp3"
    end
    audio_file_main_fixed = "#{dir}/audio_main_fixed.mp3"
    audio_file_cover_fixed = "#{dir}/audio_cover_fixed.mp3"
    `ffmpeg -i #{audio_file_main_name} -ar 48000 #{audio_file_main_fixed}`
    `ffmpeg -i #{audio_file_cover_name} -ar 48000 #{audio_file_cover_fixed}`
    return audio_file_cover_fixed, audio_file_main_fixed
end

def create_video(cover_page_file, audio_file_cover, story_page_files, durations, audio_file_main, dir, story)
  ffmpeg_cfg_file = create_cfg_file(story_page_files, durations, dir)
  orientation = story.orientation
  ext_name=".mov"
  video_modes = '-strict -2 -vsync vfr -pix_fmt yuv420p -vf fps=24 -video_track_timescale 90000 -max_muxing_queue_size 2048 -tune animation -crf 6'
  unless orientation == "portrait"
    fix_for_horizontal_stories = ' -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2"'
    video_modes = video_modes + fix_for_horizontal_stories
    ext_name=".mp4"
  end

  `ffmpeg -y -i "app/assets/videos/intro_#{orientation}#{ext_name}" #{video_modes} "#{dir}/intro.mp4"`
  `ffmpeg -y -i "#{audio_file_cover}" -i "#{dir}/1.jpg" #{video_modes} "#{dir}/cover.mp4"`
  `ffmpeg -y -i "#{audio_file_main}" -f concat -safe 0 -i "#{ffmpeg_cfg_file}" #{video_modes} "#{dir}/main.mp4"`
  `ffmpeg -y -i "app/assets/videos/outro_#{orientation}#{ext_name}" #{video_modes} "#{dir}/outro.mp4"`

  concat_cfg_file = "#{dir}/concat.cfg"
  File.open(concat_cfg_file, "w") do |f|
    f.write "file #{dir}/intro.mp4 \n"
    f.write "file #{dir}/cover.mp4 \n"
    f.write "file #{dir}/main.mp4 \n"
    f.write "file #{dir}/outro.mp4 \n"
  end
  video_file_name = "#{dir}/out.mp4"
  `ffmpeg -f concat -safe 0 -i #{concat_cfg_file} -strict -2  -max_muxing_queue_size 2048 -tune animation -crf 6 #{video_file_name}`
  return video_file_name
end

def upload_to_cloud(story, video_file, directory)
  file = directory.files.create(
        :key    => "stories/#{story.id}/videos/#{story.to_param}.mp4",
        :body   => File.open(video_file),
        :public => true,
        :metadata => {'Cache-Control' => 'public, no-cache'}
      )
    file.body= File.open(video_file),
    file.save
end

def save_story_video(story, story_revision, directory)
    dir = Dir.mktmpdir
    copy_organization_logo(story, dir)
    copy_level_bands(story, dir)
    copy_fonts(story, dir)
    story_page_files=[]
    cover_page_file = make_one_page_html(story.front_cover_page, story, dir)[0]
    story.story_pages.each do |page|
      story_page_files += make_one_page_html(page, story, dir)
    end
    durations = get_durations(story, directory)
    audio_file_cover_name, audio_file_main_name = download_audio_file(story, directory, dir)
    video_file = create_video(cover_page_file, audio_file_cover_name, story_page_files, durations, audio_file_main_name, dir, story)
    upload_to_cloud(story, video_file, directory)
end

