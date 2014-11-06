require "rails_helper"

RSpec.describe Api::V1::JobQueuesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/api/job_queues").to route_to(controller: "api/v1/job_queues", action: "index", format: :json)
    end

    it "routes to #new" do
      skip "Not yet used"
      expect(:get => "/api/job_queues/new").to route_to(controller: "api/v1/job_queues", action: "new", format: :json)
    end

    it "routes to #show" do
      expect(:get => "/api/job_queues/1").to route_to(controller: "api/v1/job_queues", action: "show", format: :json, id: "1")
    end

    it "routes to #edit" do
      skip "Not yet used"
      expect(:get => "/api/job_queues/1/edit").to route_to(controller: "api/v1/job_queues", action: "edit", format: :json, id: "1")
    end

    it "routes to #create" do
      skip "Not yet used"
      expect(:post => "/api/job_queues").to route_to(controller: "api/v1/job_queues", action: "create", format: :json)
    end

    it "routes to #update" do
      skip "Not yet used"
      expect(:put => "/api/job_queues/1").to route_to(controller: "api/v1/job_queues", action: "update", format: :json, id: "1")
    end

    it "routes to #destroy" do
      skip "Not yet used"
      expect(:delete => "/api/job_queues/1").to route_to(controller: "api/v1/job_queues", action: "destroy", format: :json, id: "1")
    end

  end
end
