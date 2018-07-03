class StatisticsController < ApplicationController
  respond_to :json
  def update
    respond_to do |format|
      format.json do
        if(params[:c]=='Story')
          if(params[:a]=='Reads')
            Story.increment!(params[:n], :reads)
          elsif(params[:a]=='Likes')
            authenticate_user!
            story = Story.find_by_id(params[:n])
            story.liked_by current_user
            story.reindex
          end
        elsif(params[:c]=='Illustration')
          if(params[:a]=='Reads')
            Illustration.increment!(params[:n], :reads)
          elsif(params[:a]=='Likes')
            authenticate_user!
            illustration = Illustration.find_by_id(params[:n])
            illustration.liked_by current_user
            illustration.reindex
          end
        elsif(params[:c]=='Popup')
          session[:viewed_popup] = true
        end
        head :ok
      end
    end
  end
  def create
    respond_to do |format|
      format.json do
        head :ok
      end
    end
  end
end
