require 'rails_helper'

RSpec.describe ErrorsController, :type => :controller do

  describe "GET error_404" do
    it "returns http success" do
      get :error_404
      expect(response).to have_http_status(404)
    end
  end

  describe "GET error_500" do
    it "returns http success" do
      get :error_500
      expect(response).to have_http_status(500)
    end
  end

  describe "GET error_422" do
    it "returns http success" do
      get :error_422
      expect(response).to have_http_status(422)
    end
  end

end
