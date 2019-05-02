class IllustrationCropsController < ApplicationController
  def show
    @illustration_crop = IllustrationCrop.find(params[:id])
    @page = @illustration_crop.page
    @story = @page.try(:story)
    respond_to do |format|
      format.json do
        render json: {
          links: [
            {
              rel: 'self',
              uri: story_page_path(@story,@page)
            },
            {
              rel: 'story',
              uri: react_stories_show_path(@story.to_param)
            },
            {
              rel: 'illustration',
              uri: illustration_path(@illustration_crop.illustration)
            },
            {
              rel: 'size1',
              uri: @illustration_crop.image.url(:size1)
            },
            {
              rel: 'size2',
              uri: @illustration_crop.image.url(:size2)
            },
            {
              rel: 'size3',
              uri: @illustration_crop.image.url(:size3)
            },
            {
              rel: 'size4',
              uri: @illustration_crop.image.url(:size4)
            },
            {
              rel: 'size5',
              uri: @illustration_crop.image.url(:size5)
            },
            {
              rel: 'size6',
              uri: @illustration_crop.image.url(:size6)
            },
            {
              rel: 'size7',
              uri: @illustration_crop.image.url(:size7)
            }
          ]
        }
      end
    end
  end
end
