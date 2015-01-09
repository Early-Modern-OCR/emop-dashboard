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
    before(:each) do
      @completed_job_queues = create_list(:job_queue, 5, status: JobStatus.processing)
      @failed_job_queues = create_list(:job_queue, 2, status: JobStatus.processing)
      @page_result = build_attributes(:page_result, batch_job: create(:batch_job), page: create(:page))
      @postproc_page = build_attributes(:postproc_page, batch_job: create(:batch_job), page: create(:page))
      @params = {
        job_queues: {
          completed: @completed_job_queues.collect{|j| j.id},
          failed: @failed_job_queues.collect{|j| { id: j.id, results: "some error message" } },
        },
        page_results: [
          @page_result,
        ],
        postproc_results: [
          @postproc_page,
        ]
      }
    end

    it 'uploads page and postproc page results', :show_in_doc do
      put '/api/batch_jobs/upload_results', @params.to_json, api_headers

      expect(response).to be_success
      expect(json['page_results']['imported']).to eq(1)
      expect(json['postproc_results']['imported']).to eq(1)
      @completed_job_queues.each do |job_queue|
        job_queue = JobQueue.find(job_queue.id)
        expect(job_queue.status.id).to eq(JobStatus.done.id)
      end
      @failed_job_queues.each do |job_queue|
        job_queue = JobQueue.find(job_queue.id)
        expect(job_queue.status.id).to eq(JobStatus.failed.id)
        expect(job_queue.results).to eq("some error message")
      end
      page_result = PageResult.find_by(page_id: @page_result['page_id'], batch_id: @page_result['batch_id'])
      expect(page_result.ocr_completed).to_not be_nil
    end

    it 'updates page and postproc page results' do
      @page_result = create_attributes(:page_result)
      @postproc_page = create_attributes(:postproc_page)
      @page_result['juxta_change_index'] = 0.1
      @postproc_page['pp_pg_quality'] = 0.1

      @params[:page_results] = [@page_result]
      @params[:postproc_results] = [@postproc_page]

      put '/api/batch_jobs/upload_results', @params.to_json, api_headers

      page_result = PageResult.find_by(page_id: @page_result['page_id'], batch_id: @page_result['batch_id'])
      postproc_page = PostprocPage.find_by(page_id: @postproc_page['page_id'], batch_job_id: @postproc_page['batch_job_id'])
      expect(response).to be_success
      expect(page_result.juxta_change_index).to eq(0.1)
      expect(postproc_page.pp_pg_quality).to eq(0.1)
    end

    it 'imports no results when no data provided' do
      @params[:page_results] = nil
      @params[:postproc_results] = nil

      put '/api/batch_jobs/upload_results', @params.to_json, api_headers

      expect(response).to be_success
      expect(json['page_results']['imported']).to eq(0)
      expect(json['postproc_results']['imported']).to eq(0)
      expect(PageResult.count).to eq(0)
      expect(PostprocPage.count).to eq(0)
    end

    it 'imports no results when empty data provided' do
      @params[:page_results] = []
      @params[:postproc_results] = []

      put '/api/batch_jobs/upload_results', @params.to_json, api_headers

      expect(response).to be_success
      expect(json['page_results']['imported']).to eq(0)
      expect(json['postproc_results']['imported']).to eq(0)
      expect(PageResult.count).to eq(0)
      expect(PostprocPage.count).to eq(0)
    end

    context "when error values are produced" do
      before(:each) do
        @postproc_page['pp_pg_quality'] = -1
        @params[:postproc_results] = [@postproc_page]
      end

      it 'should succeed' do
        put '/api/batch_jobs/upload_results', @params.to_json, api_headers
        expect(response).to be_success
      end

      it 'should have pp_pg_quality of -1.0' do
        put '/api/batch_jobs/upload_results', @params.to_json, api_headers
        expect(PostprocPage.first.pp_pg_quality).to eq(-1.0)
      end
    end
  end
end
