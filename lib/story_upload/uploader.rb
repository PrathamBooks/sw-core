require 'fileutils'
require 'csv'
class StoryUpload::Uploader
  STORY_UPLOAD_QUEUE = 'story_upload'
  def initialize
    @base_dir=::Settings.upload.base_dir
    @file_name=::Settings.upload.file_name
  end
  def check_input_file(file_name=@file_name)
    File.exist?(get_file_path('inbox',file_name))
  end

  def get_file_path(dir,file_name=@file_name)
    File.join(@base_dir,dir,file_name)
  end

  def move_file(source,dest)
    FileUtils.mv(get_file_path(source), get_file_path(dest))
  end

  def open_csv(file_name)
    CSV.read(file_name, {:headers=>true,:encoding => 'UTF-8'})
  end

  def upload
    puts "Uploading stories"
    unless check_input_file
      puts "Unable to locate file"
      return false
    end
    move_file 'inbox','inprogress'
    csv = open_csv(get_file_path('inprogress'))
    @csv_out = CSV.open(get_file_path('done'), 'wb')
    @csv_out << csv.headers
    story_uploader=::StoryUpload::StoryUploader.new(self,csv)
    csv["Story"].each_with_index do |story,index|
      if story == "" || story == nil || story.empty?
        next
      end
      rows = story_uploader.upload(index,@csv_out)
      rows.each do |row|
        @csv_out << row
      end
    end
    @csv_out.close
    Story.reindex
    return true
  end
  handle_asynchronously :upload, queue: STORY_UPLOAD_QUEUE
end
