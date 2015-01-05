require "rails_helper"

RSpec.describe Api::V1::BatchJobsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/api/batch_jobs").to route_to(controller: "api/v1/batch_jobs", action: "index", format: :json)
    end

    it "routes to #show" do
      expect(:get => "/api/batch_jobs/1").to route_to(controller: "api/v1/batch_jobs", action: "show", format: :json, id: "1")
    end

    it "routes to #page_results" do
      expect(:get => "/api/batch_jobs/1/page_results").to route_to(controller: "api/v1/batch_jobs", action: "page_results", format: :json, id: '1')
    end

    it "routes to #count" do
      expect(:get => "/api/batch_jobs/count").to route_to(controller: "api/v1/batch_jobs", action: "count", format: :json)
    end

    it "routes to #upload_results" do
      expect(:put => "/api/batch_jobs/upload_results").to route_to(controller: "api/v1/batch_jobs", action: "upload_results", format: :json)
    end
=begin
    it "routes to #new" do
      skip "Not yet used"
      expect(:get => "/api/batch_jobs/new").to route_to(controller: "api/v1/batch_jobs", action: "new", format: :json)
    end

    it "routes to #edit" do
      skip "Not yet used"
      expect(:get => "/api/batch_jobs/1/edit").to route_to(controller: "api/v1/batch_jobs", action: "edit", format: :json, id: "1")
    end

    it "routes to #create" do
      skip "Not yet used"
      expect(:post => "/api/batch_jobs").to route_to(controller: "api/v1/batch_jobs", action: "create", format: :json)
    end

    it "routes to #update" do
      skip "Not yet used"
      expect(:put => "/api/batch_jobs/1").to route_to(controller: "api/v1/batch_jobs", action: "update", format: :json, id: "1")
    end

    it "routes to #destroy" do
      skip "Not yet used"
      expect(:delete => "/api/batch_jobs/1").to route_to(controller: "api/v1/batch_jobs", action: "destroy", format: :json, id: "1")
    end
=end
  end
end
