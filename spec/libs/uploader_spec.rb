require 'fileutils'
describe "Uploader" do
  before do
    FileUtils.mkdir_p "#{Settings.upload.base_dir}/inbox"
    FileUtils.mkdir_p "#{Settings.upload.base_dir}/done"
    FileUtils.mkdir_p "#{Settings.upload.base_dir}/inprogress"
    FileUtils.cp Rails.root.join("spec","files","muchkund.epub"), "#{Settings.upload.base_dir}/inbox"
    FileUtils.cp Rails.root.join("spec","files","upload_stories.csv"), "#{Settings.upload.base_dir}/inbox/sample.csv"
    FactoryGirl.create(:english)
    FactoryGirl.create(:illustration_category, name: "People")
    FactoryGirl.create(:story_category, name: 'Nature')
    FactoryGirl.create(:front_cover_page_template_2)
    FactoryGirl.create(:back_inner_cover_page_template, default: true, orientation: 'landscape')
    FactoryGirl.create(:back_cover_page_template, default: true, orientation: 'landscape')
    FactoryGirl.create(:style,name: 'Watercolour')
    FactoryGirl.create(:story_page_template, name: 'story_page_template_4')
    FactoryGirl.create(:publisher, email: 'admin@example.com')
  end

  after do
    FileUtils.rm "#{Settings.upload.base_dir}/inbox/muchkund.epub",:force => true
    FileUtils.rm "#{Settings.upload.base_dir}/inbox/sample.csv",:force => true
  end

  before :each do
    @uploader = StoryUpload::Uploader.new
  end

  it "respond to upload" do
    uploader = StoryUpload::Uploader.new
    expect(uploader).to respond_to(:upload)
  end
  it 'should join file path' do
    expect(@uploader.get_file_path('inbox')).to eql("/tmp/inbox/sample.csv")
  end
  it 'should check existence of file' do
    expect(@uploader.check_input_file()).to be true
  end
  describe 'upload' do
    it 'should fail if input file not present' do
      allow(@uploader).to receive(:check_input_file) { false}

      result = @uploader.upload_without_delay()

      expect(result).to be false
    end
  end

end
