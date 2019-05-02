require 'utils/utils'
require 'fileutils'

class AudioUpload::AudioUploader
 
  def upload(story, dir)
    file_path = "#{dir}/#{story.to_param}"
    page_start_cue = audio_page_content(story)
    story_txt_file(story, file_path)
    convert_csv_to_vtt(file_path, story, page_start_cue) if File.exist?("#{file_path}.csv")
    lang = "#{story.language.name == "English" ? "eng" : story.language.name[0..1].downcase}"
    unless File.exist?("#{file_path}.vtt")
      `python #{Rails.root}/lib/scripts/sls.py --txt #{file_path}.txt --audio #{file_path}.mp3 --out #{file_path}.vtt --lang #{lang}`
      convert_vtt_to_csv(file_path, story, page_start_cue)
    end

    upload_to_cloud(story, dir, {cover: false, :format=>"mp3", :folder=>"audios/story"}) if File.exist?("#{file_path}.mp3")
    upload_to_cloud(story, dir, {cover: false, :format=>"csv", :folder=>"csv", :cache=>false}) if File.exist?("#{file_path}.csv")
    upload_to_cloud(story, dir, {cover: false, :format=>"vtt", :folder=>"vtt/story", :cache=>false}) if File.exist?("#{file_path}.vtt")
    upload_to_cloud(story, dir, {cover: true, :format=>"mp3", :folder=>"audios/cover"}) if File.exist?("#{dir}/cover_#{story.to_param}.mp3")
    story.is_audio = true
    story.audio_status = Story.audio_statuses[:audio_draft]
    story.save!

    FileUtils.rm_rf("#{dir}") if File.exist?("#{dir}")
  end

  def convert_csv_to_vtt(file_path, story, page_start_cue)
    csv_text = File.read("#{file_path}.csv", encoding: "ISO8859-1:utf-8")
    csv = CSV.parse(csv_text, :headers=>false, encoding: "ISO8859-1:utf-8")
    file_name = "#{file_path}.vtt"
    File.open(file_name, "w") do |f|
      f.puts "WEBVTT"
      csv.each_with_index do |value, index|
      next if index == 0
        value[2] = value[2].gsub(/\n/, "")
        value[3] = value[3].gsub(/\r\n/, "")
        value[3] = value[3].gsub(/\n/, "")
        end_time = csv[index+1] && csv[index+1][4].present? ? csv[index+1][4].gsub("_", ":").gsub("-", ".") : (value[4].gsub("_", ":").gsub("-", ".").to_time+60).strftime('%H:%M:%S.%L')
        value[4] = "#{value[4].gsub("_", ":").gsub("-", ".")}--> #{end_time}".gsub(/\n/, "")
        f.puts ""
        f.puts value[2].strip
        f.puts value[4].strip
        f.puts value[3].strip
      end
    end
  end

  def convert_vtt_to_csv(file_path, story, page_start_cue)
    file = "#{file_path}.csv"
    word_number = 1
    vtt = File.readlines("#{file_path}.vtt")
    column_headers = ["Page Number", "Word Number", "Cue Number", "Content", "Start Time"]
    CSV.open(file, 'w', write_headers: true, headers: column_headers) do |writer|
      vtt.each_with_index do |obj, index|
        next if index == 0
        if index%4==0
          cue_no = vtt[index-2].strip if vtt[index-2]
          page_no = page_start_cue[cue_no.to_i] if cue_no
          word_number = 1 if page_start_cue[cue_no.to_i] != page_start_cue[cue_no.to_i - 1]
          word = obj.gsub(/\n/, "")
          time = "#{vtt[index-1].split('-->').first}".gsub(":", "_").gsub(".", "-") if vtt[index-1]
          writer << [page_no, word_number, cue_no, word, time]
          word_number += 1
        end
      end
    end
  end

  def upload_to_cloud(story, dir, options)
    cover = options[:cover]
    format = options[:format]
    folder = options[:folder]
    if options[:cache] == false
      file = directory.files.create(
        :key    => "stories/#{story.id}/#{folder}/#{story.to_param}.#{format}",
        :body   => File.open("#{dir}/#{cover == true ? "cover_" : ""}#{story.to_param}.#{format}"),
        :public => true,
        :metadata => {'Cache-Control' => 'public, no-cache'}
      )
    else
      file = directory.files.create(
        :key    => "stories/#{story.id}/#{folder}/#{story.to_param}.#{format}",
        :body   => File.open("#{dir}/#{cover == true ? "cover_" : ""}#{story.to_param}.#{format}"),
        :public => true
    )
    end
    file.body= File.open("#{dir}/#{cover == true ? 'cover_': ""}#{story.to_param}.#{format}"),
    file.save
  end

  def audio_page_content(story)
    cue = 1
    page_start_cue = {}
    preserved_chars = [" ", "\n", "\t", "\u00A0", "\u2003"]
    story.story_pages.each_with_index do |p, index|
      content = p.content
      doc = Nokogiri::HTML::DocumentFragment.parse(content)
      doc.traverse do |node|
        if node.text?
          prev_node = node
          word = ""
          0.upto node.content.size - 1 do |i|
            char = node.content[i]
            if preserved_chars.include?(char)
              unless word.empty?
                span = Nokogiri::XML::Node.new('span', node)
                span['data-cue'] = cue
                page_start_cue[cue] = index + 1
                cue += 1
                span.content = "#{word.gsub("\u2029", " ")}"
                prev_node.add_next_sibling(span)
                prev_node = span
              end
              if preserved_chars.include?(char)
                text_node = Nokogiri::XML::Node.new('span', node)
                text_node.content = char
                prev_node.add_next_sibling(text_node)
                prev_node = text_node
              end
              word = ""
            else
              word += char
            end
          end
          unless word.empty?
            span = Nokogiri::XML::Node.new('span', node)
            span['data-cue'] = cue
            page_start_cue[cue] = index + 1
            cue += 1
            span.content = "#{word.gsub("\u2029", " ")}"
            prev_node.add_next_sibling(span)
          end
          node.remove
        end
      end
      audio_content = doc.to_html
      preserved_chars.each do |char|
        audio_content = audio_content.gsub("<span>#{char}</span>", char == "\u00A0" ? "&nbsp;" : char)
      end
      p.audio_content = audio_content
      p.save!

    end
    return page_start_cue
  end

  def story_txt_file(story, file_path)
   file_name = "#{file_path}.txt"
    File.open(file_name, "w") do |f|
      story.story_pages.each do |p|
        content = p.content
        doc = Nokogiri::HTML::DocumentFragment.parse(content)
        doc.traverse do |node|
          if node.text?
            node.content.split(" ").each do |c|
              c.split("\u00A0").each do |w|
                f.puts w.gsub("\u2029", " ")
                f.puts
              end
            end
          end
        end
      end
    end
  end
  
  def directory
    credentials =  YAML.load_file("#{Rails.root}/config/fog.yml")
    connection = Fog::Storage.new(credentials.values.first.symbolize_keys!)
    directory = connection.directories.get(Settings.fog.directory)
  end
end

