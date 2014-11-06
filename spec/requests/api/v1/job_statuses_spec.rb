require 'rails_helper'

RSpec.describe "JobStatuses", :type => :request do
  let(:api_headers) { {'Accept' => 'application/emop; version=1'} }

  describe "GET /api/job_statuses" do
    it 'sends a list of job statuses', :show_in_doc do
      FactoryGirl.create_list(:job_status, 2)
      get '/api/job_statuses', {}, api_headers

      expect(response).to be_success
      expect(json['results'].length).to eq(2)
    end
  end

  describe "GET /api/job_statuses/:id" do
    it 'retrieves a specific job status', :show_in_doc do
      job_status = FactoryGirl.create(:job_status)
      get "/api/job_statuses/#{job_status.id}", {}, api_headers

      expect(response).to be_success
      expect(json['job_status']['name']).to eq(job_status.name)
      expect(json['job_status']['id']).to eq(job_status.id)
    end
  end
end
