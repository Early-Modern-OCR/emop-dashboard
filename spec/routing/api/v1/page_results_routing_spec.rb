require "rails_helper"

RSpec.describe Api::V1::PageResultsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/api/page_results").to route_to(controller: "api/v1/page_results", action: "index", format: :json)
    end

    it "routes to #show" do
      expect(:get => "/api/page_results/1").to route_to(controller: "api/v1/page_results", action: "show", format: :json, id: "1")
    end

=begin
    it "routes to #update" do
      expect(:put => "/api/page_results/1").to route_to(controller: "api/v1/page_results", action: "update", format: :json, id: "1")
    end
    it "routes to #new" do
      skip "Not yet used"
      expect(:get => "/api/page_results/new").to route_to(controller: "api/v1/page_results", action: "new", format: :json)
    end

    it "routes to #edit" do
      skip "Not yet used"
      expect(:get => "/api/page_results/1/edit").to route_to(controller: "api/v1/page_results", action: "edit", format: :json, id: "1")
    end

    it "routes to #create" do
      skip "Not yet used"
      expect(:post => "/api/page_results").to route_to(controller: "api/v1/page_results", action: "create", format: :json)
    end

    it "routes to #destroy" do
      skip "Not yet used"
      expect(:delete => "/api/page_results/1").to route_to(controller: "api/v1/page_results", action: "destroy", format: :json, id: "1")
    end
=end
  end
end
