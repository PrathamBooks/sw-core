class ReactController < ApplicationController
  layout false
  def index
    url = request.url
    @description = 'StoryWeaver'
    @title = 'StoryWeaver'
    @url = 'https://storyweaver.org.in'
    @image = 'https://storyweaver.org.in/assets/pb-storyweaver-logo-01-4acd9848be4ca29481825c4b23848b97.svg'
    if url.include?('/stories/') && params[:id]
      story = Story.find_by_id params[:id]
      if story.present?
        @description = story.synopsis[0..100] rescue ''
        @title = story.title.to_s
        @url = url
        @image = story.front_cover_page.illustration_crop.image.url(:size7) rescue ''
      end
    elsif url.include?('/illustrations/') && params[:id]
      illustration = Illustration.find_by_id params[:id]
      if illustration.present?
        @description = illustration.attribution_text.to_s rescue ''
        @title = illustration.name.to_s
        @url =  url
        @image = illustration.image.url(:original) rescue ''
      end
    end
  end
end
