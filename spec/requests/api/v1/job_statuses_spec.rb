require 'rails_helper'

RSpec.describe "JobStatuses", :type => :request do
  let(:api_headers) do
    {
      'Accept' => 'application/emop; version=1',
      'Authorization' => "Token token=#{User.first.auth_token}",
      'Content-Type' => 'application/json',
    }
  end

  describe "Unauthorized access" do
    let(:api_headers) do
      {
        'Accept' => 'application/emop; version=1',
      }
    end

    it 'should not be successful' do
      get '/api/job_statuses', {}, api_headers
      expect(response).not_to be_success
    end
  end

  describe "GET /api/job_statuses" do
    it 'sends a list of job statuses', :show_in_doc do
      get '/api/job_statuses', {}, api_headers

      expect(response).to be_success
      expect(json['results'].length).to eq(7)
    end
  end

  describe "GET /api/job_statuses/:id" do
    it 'retrieves a specific job status', :show_in_doc do
      job_status = JobStatus.first
      get "/api/job_statuses/#{job_status.id}", {}, api_headers

      expect(response).to be_success
      expect(json['job_status']['name']).to eq(job_status.name)
      expect(json['job_status']['id']).to eq(job_status.id)
    end
  end
end
