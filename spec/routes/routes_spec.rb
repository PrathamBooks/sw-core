require 'rails_helper'

describe "Routes", :type => :routing do
#  describe "root" do
#    it "routes to home index" do 
#      expect(:get => "/").to route_to(
#        :controller => "home",
#        :action => "index"
#      )
#    end
#  end
#
  describe "routing to illustrations" do
    it "does expose list of illustrations" do
      expect(get: '/v0/illustrations').to route_to(
        controller: "illustrations",
        action: 'index'
      )
    end
  end

  describe "routing to dashboard" do
    it "does expose dashboard " do
      expect(get: '/v0/dashboard').to route_to(
        controller: "dashboard",
        action: 'index'
      )
    end
  end
end
