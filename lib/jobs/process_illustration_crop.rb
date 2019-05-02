class Jobs::ProcessIllustrationCrop < Struct.new(:illustration_id, :illustration_crop, :page,:x,:y,:w,:h)
  def perform
    illustration = Illustration.find_by(id: illustration_id)
    if illustration.nil?
      return
    else
      illustration.process_crop_background!( illustration_crop, page,nil,x,y,w,h)
    end
  end
  def queue_name
    'process_illustration_crop'
  end
end