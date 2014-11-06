require 'rails_helper'

RSpec.describe "JobQueues", :type => :request do
  let(:api_headers) { {'Accept' => 'application/emop; version=1'} }

  describe "GET /api/job_queues" do
    it 'sends a list of job queues', :show_in_doc do
      FactoryGirl.create_list(:job_queue, 2)
      get '/api/job_queues', {}, api_headers

      expect(response).to be_success
      expect(json['results'].length).to eq(2)
    end
  end

  describe "GET /api/job_queues/:id" do
    it 'retrieves a specific job queue', :show_in_doc do
      job_queue = FactoryGirl.create(:job_queue)
      get "/api/job_queues/#{job_queue.id}", {}, api_headers

      expect(response).to be_success
      expect(json['job_queue']['results']).to eq(job_queue.results)
    end
  end

  describe "GET /api/job_queues/count" do
    before(:each) do
      @not_started_status = create(:job_status)
      @done_status        = create(:done)
      @not_started        = create_list(:job_queue, 2, status: @not_started_status)
      @done               = create_list(:job_queue, 3, status: @done_status)
    end

    it 'sends the count of all job queues' do
      get '/api/job_queues/count', {}, api_headers

      expect(response).to be_success
      expect(json['job_queue']['count']).to eq(@not_started.length + @done.length)
    end

    it 'sends the count of not started job queues', :show_in_doc do
      get '/api/job_queues/count', {job_status: @not_started_status.id}, api_headers

      expect(response).to be_success
      expect(json['job_queue']['count']).to eq(@not_started.length)
    end

    it 'sends the count of done job queues' do
      get '/api/job_queues/count', {job_status: @done_status.id}, api_headers

      expect(response).to be_success
      expect(json['job_queue']['count']).to eq(@done.length)
    end
  end
end
