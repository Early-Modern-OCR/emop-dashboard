require 'rails_helper'

RSpec.describe Api::V1::BatchJobsController, :type => :request do
  let(:api_headers) do
    {
      'Accept' => 'application/emop; version=1',
      'Authorization' => "Token token=#{User.first.auth_token}",
    }
  end

  describe "Unauthorized access" do
    let(:api_headers) do
      {
        'Accept' => 'application/emop; version=1',
      }
    end

    it 'should not be successful' do
      get '/api/batch_jobs', {}, api_headers
      expect(response).not_to be_success
    end
  end

  describe "GET /api/batch_jobs" do
    it 'sends a list of batch jobs', :show_in_doc do
      FactoryGirl.create_list(:batch_job, 2)
      get '/api/batch_jobs', {}, api_headers

      expect(response).to be_success
      expect(json['results'].length).to eq(2)
    end
  end

  describe "GET /api/batch_jobs/:id" do
    it 'retrieves a specific batch job', :show_in_doc do
      batch_job = FactoryGirl.create(:batch_job)
      get "/api/batch_jobs/#{batch_job.id}", {}, api_headers

      expect(response).to be_success
      expect(json['batch_job']['name']).to eq(batch_job.name)
    end
  end

  describe "GET /api/batch_jobs/count" do
    it 'sends the count of batch jobs', :show_in_doc do
      FactoryGirl.create_list(:batch_job, 2)
      get '/api/batch_jobs/count', {}, api_headers

      expect(response).to be_success
      expect(json['batch_job']['count']).to eq(2)
    end
  end
end
