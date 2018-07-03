namespace :illustrations do
  desc "Remove all uploaded illustrations"
  task :remove_all do
    FileUtils.rm_rf(Dir["#{Rails.root}/public/system/illustrations/"])
  end

  task :reprocess_style  => :environment do
    raise "Missing STYLE!\ne.g: rake reprosess_style STYLE=size1\n" if (style = ENV['STYLE']).blank?
    puts "Reprocessing style: #{style}"
    start_index=0
    batch_size=5
    number_of_batches = Illustration.count/batch_size
    for index in start_index..number_of_batches do
      illustrations_in_batch = Illustration.order(:id).limit(batch_size).offset(index*batch_size)
      illustrations_missing_style = illustrations_in_batch.select{|i| !i.image.exists?(style)}
      illustrations_missing_style.each do |i|
        puts "reprocessing illustration #{i.id}"
        i.image.reprocess!(style)
      end
      puts "successfully processed #{index} batch"
    end
  end

  task :reprocess_crop_style  => :environment do
    raise "Missing STYLE!\ne.g: rake reprosess_style STYLE=size1\n" if (style = ENV['STYLE']).blank?
    puts "Reprocessing style: #{style}"
    start_index=0
    batch_size=5
    number_of_batches = IllustrationCrop.joins(:page).where("pages.id is not NULL").count/batch_size
    for index in start_index..number_of_batches do
      illustration_crops_in_batch = IllustrationCrop
      .joins(:page)
      .where("pages.id is not NULL")
      .order(:id)
      .limit(batch_size)
      .offset(index*batch_size)
      illustration_crops_missing_style = illustration_crops_in_batch.select{|i| !i.image.exists?(style)}
      illustration_crops_missing_style.each do |i|
        puts "reprocessing illustration crop #{i.id}"
        i.image.reprocess!(style)
      end
      puts "successfully processed #{index} batch"
    end
  end

  desc "Connect Illustrations with organisations"
  task :connect_organizations => :environment do
    Illustration.where.not(publisher_id: nil).each do |il|
        il.organization_id = il.publisher.organization_id
        il.save!
    end
  end

end
