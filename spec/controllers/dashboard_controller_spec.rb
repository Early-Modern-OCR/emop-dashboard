require 'rails_helper'

RSpec.describe DashboardController, :type => :controller do

  let(:valid_session) { {} }

  describe "GET index" do
    it "should be successful" do
      get :index, {}, valid_session
      expect(response).to be_success
    end

    it "should call JobQueue.status_summary" do
      expect(JobQueue).to receive(:status_summary)
      get :index, {}, valid_session
    end

    context 'json format' do
      it 'should set session values' do
        get :index, {format: :json, gt: 'with_gt'}, valid_session
        expect(session[:gt]).to eq('with_gt')
      end
    end

    context 'csv format' do
      let(:columns) { [ 'Work ID', 'Collection', 'Title', 'Author', 'Font', 'OCR Date', 'OCR Engine', 'OCR Batch', 'Juxta', 'RETAS' ] }
      it 'should respond to csv format' do
        get :index, {format: :csv}, valid_session
        expect(response).to be_success
      end

      it 'should send valid csv data' do
        pf = create(:print_font)
        work = create(:work, print_font: pf, collection: create(:works_collection, name: 'ECCO'))
        page = create(:page, work: work)
        ocr_engine = OcrEngine.find_by(name: 'Tesseract')
        job_type = JobType.find_by(name: 'OCR')
        batch_job = create(:batch_job, ocr_engine: ocr_engine, job_type: job_type)
        create(:job_queue, batch_job: batch_job, page: page, work: work, status: JobStatus.done)
        ocr_completed = Time.parse("Nov 09 2014 00:00Z")
        page_result = create(:page_result, batch_job: batch_job, page: page, ocr_completed: ocr_completed, juxta_change_index: 0.001, alt_change_index: nil)

        csv_data = CSV.generate({}) do |csv|
          csv << columns
          data = [
            work.id,
            'ECCO',
            work.wks_title,
            work.wks_author,
            pf.name,
            '11/09/2014 00:00',
            'Tesseract',
            "#{batch_job.id}: #{batch_job.name}",
            page_result.juxta_change_index,
            'N/A'
          ]
          csv << data
        end

        expect(subject).to receive(:send_data).with(csv_data, filename: 'emop_dashboard_results.csv') {
          subject.render nothing: true
        }
        get :index, {format: :csv}, valid_session
      end
    end
  end

  describe "GET batch" do
    it "should be successful" do
      batch_job = create(:batch_job)
      get :batch, {:id => batch_job.to_param}, valid_session
      expect(response).to be_success
    end
  end

  describe 'GET work_errors' do
    before(:each) do
      @batch_job = create(:batch_job)
      @work = create(:work)
      page = create(:page, work: @work)
      @job_queue = create(:job_queue, batch_job: @batch_job, page: page, work: @work, status: JobStatus.failed, results: 'Error')
      @page_results = create(:page_result, page: page, batch_job: @batch_job)
    end

    it 'returns error data' do
      get :work_errors, {batch: @batch_job.id, work: @work.id}, valid_session
      expect(json['work']).to eq(@work.id.to_s)
      expect(json['job']).to eq(@batch_job.name)
      expect(json['errors'][0]['page']).to eq(@page_results.page.pg_ref_number)
      expect(json['errors'][0]['error']).to eq(@job_queue.results)
    end
  end

  describe "POST create_batch" do
    before(:each) do
      @job_type = JobType.find_by(name: 'OCR')
      @ocr_engine = OcrEngine.find_by(name: 'Tesseract')
      @font = create(:font)

      @params = {
        name: 'TEST',
        type_id: @job_type.id,
        engine_id: @ocr_engine.id,
        font_id: @font.id,
        #Can't use params in params
        #params: '',
        notes: '',
      }
    end

    context "basic tests" do
      before(:each) do
        @works = create_list(:work, 2)
      end

      it "should create batch of selected works" do
        @params[:json] = {works: @works.map(&:id)}.to_json

        post :create_batch, @params

        expect(response).to be_success
        batch_job = BatchJob.find_by(name: 'TEST')
        job_queues = JobQueue.all
        expect(batch_job.job_type).to eq(@job_type)
        expect(batch_job.ocr_engine).to eq(@ocr_engine)
        expect(batch_job.font).to eq(@font)
        expect(json['total']).to eq(2)
        expect(job_queues.size).to eq(2)
        job_queues.each do |job_queue|
          expect(job_queue.batch_job).to eq(batch_job)
        end
      end

      it "should create batch of all works" do
        @params[:json] = {works: 'all'}.to_json

        post :create_batch, @params

        expect(response).to be_success
        batch_job = BatchJob.find_by(name: 'TEST')
        job_queues = JobQueue.all
        expect(batch_job.job_type).to eq(@job_type)
        expect(batch_job.ocr_engine).to eq(@ocr_engine)
        expect(batch_job.font).to eq(@font)
        expect(json['total']).to eq(2)
        expect(job_queues.size).to eq(2)
        job_queues.each do |job_queue|
          expect(job_queue.batch_job).to eq(batch_job)
        end
      end
    end

    describe 'BatchJob filters' do
      before(:each) do
        @works = create_list(:work, 2)
      end

      it "should create batch of all works - batch job filter" do
        @params[:json] = {works: 'all'}.to_json

        # Create batch used for filter
        batch_job = create(:batch_job)
        # Create job_queue used to query the batch_job
        job_queue = create(:job_queue, batch_job: batch_job, work: @works.first, page: @works.first.pages.first, status: JobStatus.done)

        post :create_batch, @params, {batch: batch_job.id}

        expect(response).to be_success
        job_queues = JobQueue.pending
        expect(json['total']).to eq(2) # existing + created
        expect(job_queues.size).to eq(1)
      end
    end

    describe "Work filters" do
      before(:each) do
        @works = create_list(:work, 2)
      end

      it "should create batch of all works - GT filter" do
        @params[:json] = {works: 'all'}.to_json

        # Set one work to be in scope of Work.with_gt
        @works.first.update!(wks_gt_number: '1')

        post :create_batch, @params, {gt: 'with_gt'}

        expect(response).to be_success
        job_queues = JobQueue.all
        expect(json['total']).to eq(1)
        expect(job_queues.size).to eq(1)
      end

      it "should create batch of all works - without GT filter" do
        @params[:json] = {works: 'all'}.to_json

        post :create_batch, @params, {gt: 'without_gt'}

        expect(response).to be_success
        job_queues = JobQueue.all
        expect(json['total']).to eq(2)
        expect(job_queues.size).to eq(2)
      end

      it "should create batch of all works - font filter" do
        @params[:json] = {works: 'all'}.to_json

        # Set one work to use different font
        new_font = create(:font)
        @works.first.update!(wks_primary_print_font: new_font.id)

        post :create_batch, @params, {font: new_font.id}

        expect(response).to be_success
        job_queues = JobQueue.all
        expect(json['total']).to eq(1)
        expect(job_queues.size).to eq(1)
      end

      it "should create batch of all works - EEBO filter" do
        @params[:json] = {works: 'all'}.to_json

        # Set one work to EEBO
        collection = create(:works_collection, name: 'EEBO')
        @works.first.update!(collection: collection)

        post :create_batch, @params, {collection: collection.id}

        expect(response).to be_success
        job_queues = JobQueue.all
        expect(json['total']).to eq(1)
        expect(job_queues.size).to eq(1)
      end

      it "should create batch of all works - ECCO filter" do
        @params[:json] = {works: 'all'}.to_json

        collection = create(:works_collection, name: 'ECCO')
        @works.first.update!(collection: collection)
        post :create_batch, @params, {collection: collection.id}

        expect(response).to be_success
        job_queues = JobQueue.all
        expect(json['total']).to eq(1)
        expect(job_queues.size).to eq(1)
      end
    end

    describe "to/from filters" do
      before(:each) do
        @works = create_list(:work, 2)
        batch_job = create(:batch_job)
        create(:job_queue, batch_job: batch_job, page: @works.first.pages.first, work: @works.first, status: JobStatus.done, proc_id: '1')
        create(:job_queue, batch_job: batch_job, page: @works.last.pages.first, work: @works.last, status: JobStatus.done, proc_id: '1')
        create(:page_result, batch_job: batch_job, page: @works.first.pages.first, ocr_completed: '2014-01-01')
        create(:page_result, batch_job: batch_job, page: @works.last.pages.first, ocr_completed: '2013-01-01')
      end

      it "should create batch of all works - from filter" do
        @params[:json] = {works: 'all'}.to_json

        post :create_batch, @params, {from: '2013-01-01'}

        expect(response).to be_success
        job_queues = JobQueue.all
        expect(json['total']).to eq(3) # 2 fixtures + 1 created
        expect(json['pending']).to eq(1)
      end

      it "should create batch of all works - to filter" do
        @params[:json] = {works: 'all'}.to_json

        post :create_batch, @params, {to: '2013-01-02'}

        expect(response).to be_success
        job_queues = JobQueue.all
        expect(json['total']).to eq(3) # 2 fixtures + 1 created
        expect(json['pending']).to eq(1)
      end

      it "should create batch of all works - to/from filter" do
        @params[:json] = {works: 'all'}.to_json

        post :create_batch, @params, {from: '2013-01-01', to: '2014-01-01'}

        expect(response).to be_success
        job_queues = JobQueue.all
        expect(json['total']).to eq(2) # 2 fixtures + 0 created
        expect(json['pending']).to eq(0)
      end
    end

    describe 'JobQueue filters' do
      before(:each) do
        @works = create_list(:work, 20)
        @batch_job = create(:batch_job)
        @job_queues = []

        # Create 5 not started results
        (0..4).each do |i|
          page = @works[i].pages.first
          @job_queues << create(:job_queue, batch_job: @batch_job, page: page, work: page.work, status: JobStatus.not_started)
        end

        # Create 4 processing results
        (5..8).each do |i|
          page = @works[i].pages.first
          @job_queues << create(:job_queue, batch_job: @batch_job, page: page, work: page.work, status: JobStatus.processing)
        end

        # Create 3 completed results
        (9..11).each do |i|
          page = @works[i].pages.first
          @job_queues << create(:job_queue, batch_job: @batch_job, page: page, work: page.work, status: JobStatus.done)
          create(:page_result, page: page, batch_job: @batch_job, ocr_completed: Time.now)
        end

        # Create 2 failed results
        (12..13).each do |i|
          page = @works[i].pages.first
          @job_queues << create(:job_queue, batch_job: @batch_job, page: page, work: page.work, status: JobStatus.failed)
          create(:page_result, page: page, batch_job: @batch_job)
        end

        # Create 1 ingest failed results
        (14..14).each do |i|
          page = @works[i].pages.first
          @job_queues << create(:job_queue, batch_job: @batch_job, page: page, work: page.work, status: JobStatus.ingest_failed)
          create(:page_result, page: page, batch_job: @batch_job)
        end
      end

      it "should create batch of all works - ocr_done filter" do
        @params[:json] = {works: 'all'}.to_json

        post :create_batch, @params, {ocr: 'ocr_done'}

        expect(response).to be_success
        job_queues = JobQueue.where(status: JobStatus.not_started)
        expect(json['total']).to eq(18) # ALL (15) + created (3)
        expect(job_queues.size).to eq(8) # Existing (5) + created (3)
      end


      it "should create batch of all works - ocr_sched filter" do
        @params[:json] = {works: 'all'}.to_json

        post :create_batch, @params, {ocr: 'ocr_sched'}

        expect(response).to be_success
        job_queues = JobQueue.where(status: JobStatus.not_started)
        expect(json['total']).to eq(24) # ALL (15) + created (9)
        expect(job_queues.size).to eq(14) # Existing (5) + created (9)
      end


      it "should create batch of all works - ocr_ingest filter" do
        @params[:json] = {works: 'all'}.to_json

        post :create_batch, @params, {ocr: 'ocr_ingest'}

        expect(response).to be_success
        job_queues = JobQueue.where(status: JobStatus.not_started)
        expect(json['total']).to eq(18) # ALL (15) + created (3)
        expect(job_queues.size).to eq(8) # Existing (5) + created (3)
      end

      it "should create batch of all works - ocr_ingest_error filter" do
        @params[:json] = {works: 'all'}.to_json

        post :create_batch, @params, {ocr: 'ocr_ingest_error'}

        expect(response).to be_success
        job_queues = JobQueue.where(status: JobStatus.not_started)
        expect(json['total']).to eq(16) # ALL (15) + created (1)
        expect(job_queues.size).to eq(6) # Existing (5) + created (1)
      end

      it "should create batch of all works - ocr_none filter" do
        @params[:json] = {works: 'all'}.to_json
        post :create_batch, @params, {ocr: 'ocr_none'}

        expect(response).to be_success
        job_queues = JobQueue.where(status: JobStatus.not_started)
        num = @works.size - @job_queues.size
        expect(json['total']).to eq(@job_queues.size + num) # ALL (15) + created (1)
        expect(job_queues.size).to eq(5 + num) # Existing (5) + created (1)
      end

      it "should create batch of all works - ocr_error filter" do
        @params[:json] = {works: 'all'}.to_json

        post :create_batch, @params, {ocr: 'ocr_error'}

        expect(response).to be_success
        job_queues = JobQueue.where(status: JobStatus.not_started)
        expect(json['total']).to eq(17) # ALL (15) + created (2)
        expect(job_queues.size).to eq(7) # Existing (5) + created (2)
      end
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

      job_queues.each do |job_queue|
        expect(JobQueue.find(job_queue.id).status).to eq(JobStatus.not_started)
      end
    end
  end
end
