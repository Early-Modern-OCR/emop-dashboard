require "rails_helper"

RSpec.describe Api::V1::PagesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/api/pages").to route_to(controller: "api/v1/pages", action: "index", format: :json)
    end

    it "routes to #show" do
      expect(:get => "/api/pages/1").to route_to(controller: "api/v1/pages", action: "show", format: :json, id: "1")
    end

    it "routes to #update" do
      expect(:put => "/api/pages/1").to route_to(controller: "api/v1/pages", action: "update", format: :json, id: "1")
    end
=begin
    it "routes to #new" do
      skip "Not yet used"
      expect(:get => "/api/pages/new").to route_to(controller: "api/v1/pages", action: "new", format: :json)
    end

    it "routes to #edit" do
      skip "Not yet used"
      expect(:get => "/api/pages/1/edit").to route_to(controller: "api/v1/pages", action: "edit", format: :json, id: "1")
    end

    it "routes to #create" do
      skip "Not yet used"
      expect(:post => "/api/pages").to route_to(controller: "api/v1/pages", action: "create", format: :json)
    end

    it "routes to #destroy" do
      skip "Not yet used"
      expect(:delete => "/api/pages/1").to route_to(controller: "api/v1/pages", action: "destroy", format: :json, id: "1")
    end
=end
  end
end
