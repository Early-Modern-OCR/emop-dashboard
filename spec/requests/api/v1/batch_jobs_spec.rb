require 'rails_helper'

RSpec.describe Api::V1::BatchJobsController, :type => :request do
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
      get '/api/batch_jobs', {}, api_headers
      expect(response).not_to be_success
    end
  end

  describe "GET /api/batch_jobs" do
    it 'sends a paginated list of batch jobs' do
      batch_jobs = FactoryGirl.create_list(:batch_job, 30)
      get '/api/batch_jobs', {}, api_headers

      expect(response).to be_success
      expect(json['total']).to eq(30)
      expect(json['subtotal']).to eq(25)
      expect(json['page']).to eq(1)
      expect(json['per_page']).to eq(25)
      expect(json['total_pages']).to eq(2)
      expect(json['results'].length).to eq(25)
    end

    it 'sends a list of batch jobs', :show_in_doc do
      batch_jobs = FactoryGirl.create_list(:batch_job, 2)
      get '/api/batch_jobs', {}, api_headers

      expect(response).to be_success
      expect(json['total']).to eq(2)
      expect(json['subtotal']).to eq(2)
      expect(json['page']).to eq(1)
      expect(json['per_page']).to eq(2)
      expect(json['total_pages']).to eq(1)
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

  describe "PUT /api/batch_jobs/upload_results" do
    it 'uploads page and postproc page results', :show_in_doc do
      @completed_job_queues = create_list(:job_queue, 5, status: JobStatus.processing)
      @failed_job_queues = create_list(:job_queue, 2, status: JobStatus.processing)

      data = {
        job_queues: {
          completed: @completed_job_queues.collect{|j| j.id},
          failed: @failed_job_queues.collect{|j| j.id},
        },
        page_results: [
          build_attributes(:page_result),
        ],
        postproc_results: [
          build_attributes(:postproc_page),
        ]
      }

      put '/api/batch_jobs/upload_results', data.to_json, api_headers

      expect(response).to be_success
      expect(json['page_results']['imported']).to eq(1)
      expect(json['postproc_results']['imported']).to eq(1)
    end
  end
end
