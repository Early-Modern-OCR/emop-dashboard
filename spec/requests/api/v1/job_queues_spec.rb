require 'rails_helper'

RSpec.describe "JobQueues", :type => :request do
  let(:api_headers) { {'Accept' => 'application/emop; version=1'} }

  before(:each) do
    @not_started_status = create(:job_status)
    @processing_status  = create(:processing)
    @done_status        = create(:done)
  end

  describe "GET /api/job_queues" do
    it 'sends a list of job queues', :show_in_doc do
      job_queues = create_list(:job_queue, 2, status: @not_started_status)
      get '/api/job_queues', {}, api_headers

      expect(response).to be_success
      expect(json['results'].length).to eq(job_queues.length)
    end

    it 'sends a list of not started job queues', :show_in_doc do
      job_queues_not_started = create_list(:job_queue, 2, status: @not_started_status)
      job_queues_done = create_list(:job_queue, 3, status: @done_status)

      get '/api/job_queues', {job_status: @not_started_status.id}, api_headers

      expect(response).to be_success
      expect(json['results'].length).to eq(job_queues_not_started.length)
    end
  end

  describe "GET /api/job_queues/:id" do
    it 'retrieves a specific job queue', :show_in_doc do
      job_queue = create(:job_queue, status: @not_started_status)
      get "/api/job_queues/#{job_queue.id}", {}, api_headers

      expect(response).to be_success
      expect(json['job_queue']['id']).to eq(job_queue.id)
    end
  end

  describe "GET /api/job_queues/count" do
    before(:each) do
      @job_queues_not_started = create_list(:job_queue, 2, status: @not_started_status)
      @job_queues_done        = create_list(:job_queue, 3, status: @done_status)
    end

    it 'sends the count of all job queues' do
      get '/api/job_queues/count', {}, api_headers

      expect(response).to be_success
      expect(json['job_queue']['count']).to eq(@job_queues_not_started.length + @job_queues_done.length)
    end

    it 'sends the count of not started job queues', :show_in_doc do
      get '/api/job_queues/count', {job_status: @not_started_status.id}, api_headers

      expect(response).to be_success
      expect(json['job_queue']['count']).to eq(@job_queues_not_started.length)
    end

    it 'sends the count of done job queues' do
      get '/api/job_queues/count', {job_status: @done_status.id}, api_headers

      expect(response).to be_success
      expect(json['job_queue']['count']).to eq(@job_queues_done.length)
    end
  end

  describe "PUT /api/job_queues/reserve" do
    it 'reserves multiple items from job_queues', :show_in_doc do
      create_list(:job_queue, 5, status: @not_started_status)

      put '/api/job_queues/reserve', {job_queue: {num_pages: 2}}, api_headers

      expect(response).to be_success
      expect(json['requested']).to eq(2)
      expect(json['reserved']).to eq(2)
      expect(json['proc_id']).to_not be_empty
      expect(json['results'].length).to eq(2)
    end
  end
end
