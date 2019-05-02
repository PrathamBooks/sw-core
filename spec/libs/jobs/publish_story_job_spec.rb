describe "Publish Story Job" do
  before(:each) do
    Delayed::Job.destroy_all
    @front_cover_page_template = FactoryGirl.create(:front_cover_page_template, default: true,orientation: 'landscape')
    @back_cover_page_template = FactoryGirl.create(:back_cover_page_template, default: true, orientation: 'landscape')
    @back_inner_cover_page_template = FactoryGirl.create(:back_inner_cover_page_template, default: true, orientation: 'landscape')
    @story_to_publish = FactoryGirl.create(:story,status: Story.statuses[:publish_pending])
    @page = FactoryGirl.create(:story_page, story: @story_to_publish)
    generate_illustration_crop(@page)
    @job = Jobs::PublishStoryJob.new(@story_to_publish.id)
  end
  it "should have a queue name of story_publish" do
    expect(@job.queue_name).to eql('story_publish')
  end

  it "should publish story if all images are uploaded" do
    @job.perform

    @story_to_publish.reload
    expect(@story_to_publish.published?).to be true
  end

  # it "should not publish story if all images are not uploaded" do
  #   @job.perform
  #
  #   @story_to_publish.reload
  #   expect(@story_to_publish.publish_pending?).to be true
  # end
end
