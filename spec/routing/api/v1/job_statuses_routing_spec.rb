require "rails_helper"

RSpec.describe Api::V1::JobStatusesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/api/job_statuses").to route_to(controller: "api/v1/job_statuses", action: "index", format: :json)
    end

    it "routes to #show" do
      expect(:get => "/api/job_statuses/1").to route_to(controller: "api/v1/job_statuses", action: "show", format: :json, id: "1")
    end
=begin
    it "routes to #new" do
      skip "Not yet used"
      expect(:get => "/api/job_statuses/new").to route_to(controller: "api/v1/job_statuses", action: "new", format: :json)
    end

    it "routes to #edit" do
      skip "Not yet used"
      expect(:get => "/api/job_statuses/1/edit").to route_to(controller: "api/v1/job_statuses", action: "edit", format: :json, id: "1")
    end

    it "routes to #create" do
      skip "Not yet used"
      expect(:post => "/api/job_statuses").to route_to(controller: "api/v1/job_statuses", action: "create", format: :json)
    end

    it "routes to #update" do
      skip "Not yet used"
      expect(:put => "/api/job_statuses/1").to route_to(controller: "api/v1/job_statuses", action: "update", format: :json, id: "1")
    end

    it "routes to #destroy" do
      skip "Not yet used"
      expect(:delete => "/api/job_statuses/1").to route_to(controller: "api/v1/job_statuses", action: "destroy", format: :json, id: "1")
    end
=end
  end
end
