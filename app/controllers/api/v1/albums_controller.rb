class Api::V1::AlbumsController < Api::V1::ApplicationController
  
  respond_to :json

  def show
  	@album = Album.find(params[:id])

  rescue ActiveRecord::RecordNotFound 
    resource_not_found
  end



end