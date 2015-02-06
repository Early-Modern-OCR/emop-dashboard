require "rails_helper"

RSpec.describe DashboardController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/dashboard/index").to route_to(controller: "dashboard", action: "index")
    end

    it "routes to #batch" do
      expect(:get => "/dashboard/batch/1").to route_to(controller: "dashboard", action: "batch", id: "1")
    end

    it "routes to #batch" do
      expect(:post => "/dashboard/batch").to route_to(controller: "dashboard", action: "create_batch")
    end

    it "routes to #reschedule" do
      expect(:post => "/dashboard/reschedule").to route_to(controller: "dashboard", action: "reschedule")
    end

    it "routes to #get_work_errors" do
      expect(:get => "/dashboard/1/2/error").to route_to(controller: "dashboard", action: "get_work_errors", batch: "1", work: "2")
    end
  end
end
