require 'rails_helper'

RSpec.describe "Dashboard", :type => :request do
  describe "GET /dashboard" do
    it "works! (now write some real specs)" do
      get dashboard_index_path
      expect(response.status).to be(200)
    end
  end
end
