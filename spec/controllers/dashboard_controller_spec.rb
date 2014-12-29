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

  describe "POST reschedule" do
    it "should reschedule a batch job" do
      batch_job = create(:batch_job)
      work = create(:work)
      page = create(:page, work: work)
      job_queue = create(:job_queue, batch_job: batch_job, page: page, work: work, status: JobStatus.failed, proc_id: '00001')
      page_result = create(:page_result, batch_job: batch_job, page: page)
      postproc_page = create(:postproc_page, batch_job: batch_job, page: page)
      data = {
        jobs: [{work: work.id, batch: batch_job.id}].to_json
      }
      post :reschedule, data

      expect { PageResult.find(page_result.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect { PostprocPage.find(postproc_page.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(JobQueue.find(job_queue.id).status).to eq(JobStatus.not_started)
    end

    it "should reschedule multiple batch job" do
      jobs = []
      job_queues = []
      works = create_list(:work, 2)
      works.each do |work|
        batch_job = create(:batch_job)
        page = create(:page, work: work)
        job_queues << create(:job_queue, batch_job: batch_job, page: page, work: work, status: JobStatus.failed, proc_id: '00001')
        create(:page_result, batch_job: batch_job, page: page)
        create(:postproc_page, batch_job: batch_job, page: page)
        jobs << {work: work.id, batch: batch_job.id}
      end

      data = {
        jobs: jobs.to_json
      }
      post :reschedule, data

      expect(PageResult.all).to be_empty
      expect(PostprocPage.all).to be_empty
      job_queues.each do |job_queue|
        expect(JobQueue.find(job_queue.id).status).to eq(JobStatus.not_started)
      end
    end
  end
end
