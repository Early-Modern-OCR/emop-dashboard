require 'rails_helper'

RSpec.describe "JobQueues", :type => :request do
  let(:api_headers) { {'Accept' => 'application/emop; version=1'} }

  before(:each) do
    @not_started_status = create(:job_status)
    @done_status        = create(:done)
  end

  describe "GET /api/job_queues" do
    it 'sends a list of job queues', :show_in_doc do
      job_queues = create_list(:job_queue, 2)
      get '/api/job_queues', {}, api_headers

      expect(response).to be_success
      expect(json['results'].length).to eq(job_queues.length)
    end

    it 'sends a list of not started job queues', :show_in_doc do
      job_queues_not_started = create_list(:job_queue, 2, status: @not_started_status)
      job_queues_done = create_list(:job_queue, 3, status: @done_status)

      get '/api/job_queues', {status: @not_started_status.id}, api_headers

      expect(response).to be_success
      expect(json['results'].length).to eq(job_queues_not_started.length)
    end
  end

  describe "GET /api/job_queues/:id" do
    it 'retrieves a specific job queue', :show_in_doc do
      job_queue = create(:job_queue)
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
      get '/api/job_queues/count', {status: @not_started_status.id}, api_headers

      expect(response).to be_success
      expect(json['job_queue']['count']).to eq(@job_queues_not_started.length)
    end

    it 'sends the count of done job queues' do
      get '/api/job_queues/count', {status: @done_status.id}, api_headers

      expect(response).to be_success
      expect(json['job_queue']['count']).to eq(@job_queues_done.length)
    end
  end
end
