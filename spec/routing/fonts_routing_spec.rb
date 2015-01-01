require "rails_helper"

RSpec.describe FontsController, :type => :routing do
  describe "routing" do

    it "routes to #create_training_font" do
      expect(:post => "/fonts/training_font").to route_to(controller: "fonts", action: "create_training_font")
    end

    it "routes to #set_print_font" do
      expect(:post => "/fonts/print_font").to route_to(controller: "fonts", action: "set_print_font")
    end
  end
end
