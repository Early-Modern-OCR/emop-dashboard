require "rails_helper"

RSpec.describe ResultsController, :type => :routing do
  describe "routing" do

    it "routes to #show" do
      expect(:get => "/results").to route_to(controller: "results", action: "show")
    end

    it "routes to #page_image" do
      expect(:get => "/results/1/page/2").to route_to(controller: "results", action: "page_image", work: "1", num: "2")
    end

    it "routes to #create_batch" do
      expect(:post => "/results/batch").to route_to(controller: "results", action: "create_batch")
    end

    it "routes to #page_text" do
      expect(:get => "/results/1/text").to route_to(controller: "results", action: "page_text", id: "1")
    end

    it "routes to #page_hocr" do
      expect(:get => "/results/1/hocr").to route_to(controller: "results", action: "page_hocr", id: "1")
    end

    it "routes to #page_error" do
      expect(:get => "/results/1/2/error").to route_to(controller: "results", action: "page_error", batch: "1", page: "2")
    end

    it "routes to #reschedule" do
      expect(:post => "/results/reschedule").to route_to(controller: "results", action: "reschedule")
    end
  end
end
