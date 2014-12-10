require 'rails_helper'

RSpec.describe DashboardController, :type => :controller do

  let(:valid_session) { {} }

  describe "GET index" do
    it "should be successful" do
      get :index, {}, valid_session
      expect(response).to be_success
    end
  end

  describe "GET batch" do
    it "should be successful" do
      batch_job = create(:batch_job)
      get :batch, {:id => batch_job.to_param}, valid_session
      expect(response).to be_success
    end
  end

end
