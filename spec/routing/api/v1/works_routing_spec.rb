require "rails_helper"

RSpec.describe Api::V1::WorksController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/api/works").to route_to(controller: "api/v1/works", action: "index", format: :json)
    end

    it "routes to #show" do
      expect(:get => "/api/works/1").to route_to(controller: "api/v1/works", action: "show", format: :json, id: "1")
    end

    it "routes to #update" do
      expect(:put => "/api/works/1").to route_to(controller: "api/v1/works", action: "update", format: :json, id: "1")
    end
=begin
    it "routes to #new" do
      skip "Not yet used"
      expect(:get => "/api/works/new").to route_to(controller: "api/v1/works", action: "new", format: :json)
    end

    it "routes to #edit" do
      skip "Not yet used"
      expect(:get => "/api/works/1/edit").to route_to(controller: "api/v1/works", action: "edit", format: :json, id: "1")
    end

    it "routes to #create" do
      skip "Not yet used"
      expect(:post => "/api/works").to route_to(controller: "api/v1/works", action: "create", format: :json)
    end

    it "routes to #destroy" do
      skip "Not yet used"
      expect(:delete => "/api/works/1").to route_to(controller: "api/v1/works", action: "destroy", format: :json, id: "1")
    end
=end
  end
end
