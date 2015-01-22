require 'rails_helper'

RSpec.describe "JobQueues", :type => :request do
  let(:api_headers) do
    {
      'Accept' => 'application/emop; version=1',
      'Authorization' => "Token token=#{User.first.auth_token}",
      'Content-Type' => 'application/json',
    }
  end

  before(:each) do
    @not_started_status = JobStatus.not_started
    @processing_status  = JobStatus.processing
    @done_status        = JobStatus.done
  end

  describe "Unauthorized access" do
    let(:api_headers) do
      {
        'Accept' => 'application/emop; version=1',
      }
    end

    it 'should not be successful' do
      get '/api/job_queues', {}, api_headers
      expect(response).not_to be_success
    end
  end

  describe "GET /api/job_queues" do
    it 'sends a paginated list of job queues' do
      job_queues = create_list(:job_queue, 30, status: @not_started_status)
      get '/api/job_queues', {}, api_headers

      expect(response).to be_success
      expect(json['total']).to eq(30)
      expect(json['subtotal']).to eq(25)
      expect(json['page']).to eq(1)
      expect(json['per_page']).to eq(25)
      expect(json['total_pages']).to eq(2)
      expect(json['results'].length).to eq(25)
    end

    it 'sends a list of job queues', :show_in_doc do
      job_queues = create_list(:job_queue, 2, status: @not_started_status)
      get '/api/job_queues', {}, api_headers

      expect(response).to be_success
      expect(json['total']).to eq(2)
      expect(json['subtotal']).to eq(2)
      expect(json['page']).to eq(1)
      expect(json['per_page']).to eq(2)
      expect(json['total_pages']).to eq(1)
      expect(json['results'].length).to eq(2)
    end

    it 'sends a list of not started job queues', :show_in_doc do
      job_queues_not_started = create_list(:job_queue, 2, status: @not_started_status)
      job_queues_done = create_list(:job_queue, 3, status: @done_status)

      get '/api/job_queues', {job_status_id: @not_started_status.id}, api_headers

      expect(response).to be_success
      expect(json['total']).to eq(2)
      expect(json['subtotal']).to eq(2)
      expect(json['page']).to eq(1)
      expect(json['per_page']).to eq(2)
      expect(json['total_pages']).to eq(1)
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
      get '/api/job_queues/count', {job_status_id: @not_started_status.id}, api_headers

      expect(response).to be_success
      expect(json['job_queue']['count']).to eq(@job_queues_not_started.length)
    end

    it 'sends the count of done job queues' do
      get '/api/job_queues/count', {job_status_id: @done_status.id}, api_headers

      expect(response).to be_success
      expect(json['job_queue']['count']).to eq(@job_queues_done.length)
    end
  end

  describe "PUT /api/job_queues/reserve" do
    it 'reserves multiple items from job_queues', :show_in_doc do
      create_list(:job_queue, 5, status: @not_started_status)
      @time_now = Time.parse("Nov 09 2014")
      allow(Time).to receive(:now).and_return(@time_now)

      put '/api/job_queues/reserve', {job_queue: {num_pages: 2}}.to_json, api_headers

      expect(response).to be_success
      expect(json['requested']).to eq(2)
      expect(json['reserved']).to eq(2)
      expect(json['proc_id']).to_not be_empty
      expect(json['results'].length).to eq(2)
    end

    it 'results contains associations' do
      job_queues = create_list(:job_queue, 5, status: @not_started_status)
      @time_now = Time.parse("Nov 09 2014")
      allow(Time).to receive(:now).and_return(@time_now)

      put '/api/job_queues/reserve', {job_queue: {num_pages: 2}}.to_json, api_headers

      job_queue = JobQueue.find(job_queues.first.id)
      result = json['results'].select { |j| j['id'] == job_queue.id }.first
      expect(result['status']['id']).to eq(job_queue.status.id)
      expect(result['batch_job']['id']).to eq(job_queue.batch_job.id)
      expect(result['page']['id']).to eq(job_queue.page.id)
      expect(result['work']['id']).to eq(job_queue.work.id)
      expect(result['page_result']).to be_nil
      expect(result['postproc_result']).to be_nil
    end

    it 'results contains existing page_results', :show_in_doc do
      job_queues = create_list(:job_queue, 5)
      page_result = create(:page_result, page: job_queues.first.page, batch_job: job_queues.first.batch_job)
      postproc_page = create(:postproc_page, page: job_queues.first.page, batch_job: job_queues.first.batch_job)
      @time_now = Time.parse("Nov 09 2014")
      allow(Time).to receive(:now).and_return(@time_now)

      put '/api/job_queues/reserve', {job_queue: {num_pages: 2}}.to_json, api_headers

      job_queue = JobQueue.find(job_queues.first.id)
      result = json['results'].select { |j| j['id'] == job_queue.id }.first
      expect(result['page_result']['id']).to eq(page_result.id)
      expect(result['postproc_result']['id']).to eq(postproc_page.id)
    end

    it 'sets proc_id for job_queue' do
      job_queue = create(:job_queue, status: @not_started_status)
      @time_now = Time.parse("Nov 09 2014")
      allow(Time).to receive(:now).and_return(@time_now)

      put '/api/job_queues/reserve', {job_queue: {num_pages: 1}}.to_json, api_headers
      results = json['results']

      expect(response).to be_success
      expect(json['requested']).to eq(1)
      expect(json['reserved']).to eq(1)
      expect(json['proc_id']).to_not be_empty
      expect(results.length).to eq(1)

      @job_queue = JobQueue.find(job_queue.id)
      expect(@job_queue.proc_id).to eq(json['proc_id'])
      expect(@job_queue.proc_id).to eq(results.first['proc_id'])
    end
  end
end
