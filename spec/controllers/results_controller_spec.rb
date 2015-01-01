require 'rails_helper'

RSpec.describe ResultsController, :type => :controller do

  let(:valid_session) { {} }

  describe "GET show" do
    before(:each) do
      @print_font = create(:print_font)
      @work = create(:work, print_font: @print_font)
      @batch_job = create(:batch_job)

      @params = {
        work: @work.id,
        batch: @batch_job.id,
      }
    end

    it "should respond successfully" do
      get :show, @params

      expect(response).to be_success
    end

    it "should set instance variables" do
      get :show, @params

      expect(assigns(:work_id)).to eq(@work.id.to_s)
      expect(assigns(:batch_id)).to eq(@batch_job.id.to_s)
      expect(assigns(:work_title)).to eq(@work.wks_title)
      expect(assigns(:batch)).to eq("#{@batch_job.id}: #{@batch_job.name}")
      expect(assigns(:print_font)).to eq(@print_font.name)
    end

    it "should set batch 'Not Applicable'" do
      @params[:batch] = nil
      get :show, @params

      expect(assigns(:batch)).to eq("Not Applicable")
    end

    it "should set print_font 'Not Set'" do
      @work.update!(print_font: nil)
      get :show, @params

      expect(assigns(:print_font)).to eq("Not Set")
    end
  end

 describe "GET fetch" do
    before(:each) do
      @print_font = create(:print_font)
      @work = create(:work, print_font: @print_font)
      @page = @work.pages.first
      @batch_job = create(:batch_job)
      @job_queue = create(:job_queue, page: @page, work: @work, batch_job: @batch_job, status: JobStatus.done)
      @page_result = create(:page_result, page: @page, batch_job: @batch_job)

      @params = {
        work: @work.id,
        batch: @batch_job.id,
      }
    end

    it "should respond successfully" do
      get :fetch, @params

      expect(response).to be_success
    end

    it "should not respond successfully" do
      @params[:work] = nil
      get :fetch, @params

      expect(response).to_not be_success
    end

    it "should render page info" do
      @params[:batch] = nil
      get :fetch, @params

      expect(json['isEcho']).to be_nil
      expect(json['iTotalRecords']).to eq(@work.pages.count)
      expect(json['iTotalDisplayRecords']).to eq(@work.pages.count)
      expected_data = {
        'page_select' => "<input class='sel-cb' type='checkbox' id='sel-page-#{@work.pages.first.id}'>",
        'detail_link' => "<div class='detail-link disabled'>",
        'ocr_text' => "<div class='ocr-txt  disabled' title='View OCR text output'>",
        'ocr_hocr' => "<div class='ocr-hocr  disabled' title='View hOCR output'>",
        'status' => "<div  class='status-icon success' title='Success'></div>",
        'page_number' => @page.pg_ref_number,
        'page_select' => "<input class='sel-cb' type='checkbox' id='sel-page-#{@work.pages.first.id}'>",
        'juxta_accuracy' => "-",
        'retas_accuracy' => "-",
        'page_image' => "<a href=\"/results/#{@work.id}/page/#{@page.pg_ref_number}\"><div title='View page image' class='page-view'></div></a>",
      }
      expect(json['data']).to include(expected_data)
    end

    it "should render batch results" do
      get :fetch, @params

      expect(json['isEcho']).to be_nil
      expect(json['iTotalRecords']).to eq(@work.pages.count)
      expect(json['iTotalDisplayRecords']).to eq(@work.pages.count)
      expected_data = {
        'page_select' => "<input class='sel-cb' type='checkbox' id='sel-page-#{@work.pages.first.id}'>",
        'ocr_text' => "<div id='result-#{@page_result.id}' class='ocr-txt' title='View OCR text output'>",
        'ocr_hocr' => "<div id='hocr-#{@page_result.id}' class='ocr-hocr' title='View hOCR output'>",
        'juxta_accuracy' => @page_result.juxta_change_index,
        'retas_accuracy' => @page_result.alt_change_index,
        'detail_link' => "<a href='/juxta?work=#{@work.id}&batch=#{@batch_job.id}&page=#{@page.pg_ref_number}&result=#{@page_result.id}' title='View side-by-side comparison with GT'><div class='juxta-link'></div></a>",
        'status' => "<div  class='status-icon success' title='Success'></div>",
        'page_number' => @page.pg_ref_number,
        'page_image' => "<a href=\"/results/#{@work.id}/page/#{@page.pg_ref_number}\"><div title='View page image' class='page-view'></div></a>",
      }
      expect(json['data']).to include(expected_data)
    end

    it "should render batch results without Juxta data" do
      @page_result.update!(juxta_change_index: nil)
      get :fetch, @params

      expect(json['isEcho']).to be_nil
      expect(json['iTotalRecords']).to eq(@work.pages.count)
      expect(json['iTotalDisplayRecords']).to eq(@work.pages.count)
      expected_data = {
        'page_select' => "<input class='sel-cb' type='checkbox' id='sel-page-#{@work.pages.first.id}'>",
        'ocr_text' => "<div id='result-#{@page_result.id}' class='ocr-txt' title='View OCR text output'>",
        'ocr_hocr' => "<div id='hocr-#{@page_result.id}' class='ocr-hocr' title='View hOCR output'>",
        'juxta_accuracy' => '-',
        'retas_accuracy' => '-',
        'detail_link' => "<div class='juxta-link disabled'>",
        'status' => "<div  class='status-icon success' title='Success'></div>",
        'page_number' => @page.pg_ref_number,
        'page_image' => "<a href=\"/results/#{@work.id}/page/#{@page.pg_ref_number}\"><div title='View page image' class='page-view'></div></a>",
      }
      expect(json['data']).to include(expected_data)
    end
  end

 describe "GET get_page_text" do
    before(:each) do
      @print_font = create(:print_font)
      @work = create(:work, print_font: @print_font)
      @page = @work.pages.first
      @batch_job = create(:batch_job)
      @job_queue = create(:job_queue, page: @page, work: @work, batch_job: @batch_job, status: JobStatus.done)
      @page_result = create(:page_result, page: @page, batch_job: @batch_job)

      @params = {
        id: @page_result.id,
      }
      # Mock directory storing OCR output
      @emop_path_prefix = Dir.mktmpdir
      allow(Rails.application.secrets).to receive(:emop_path_prefix) { @emop_path_prefix }
      # Mock text output
      txt_filename = File.join(@emop_path_prefix, @page_result.ocr_text_path)
      @file = double('ocr-text-output')
      allow(File).to receive(:open).with(txt_filename, 'r').and_return(@file)
      allow(@file).to receive(:read).and_return('ocr-text-output')
      allow(ResultsController).to receive(:get_idhmc_page).with(@page_result.ocr_text_path).and_return([txt_filename, 'ocr-text-output'])
    end

    it "should respond successfully" do
      get :get_page_text, @params

      expect(response).to be_success
    end

    it "should respond with page result information" do
      get :get_page_text, @params

      expect(json['page']).to eq(@page.pg_ref_number)
      expect(json['content']).to eq('ocr-text-output')
    end

    it "should respond with page result information for IDHMC page" do
      #TODO Move this logic into model
      ext = File.extname(@page_result.ocr_text_path)
      name = File.basename(@page_result.ocr_text_path, ext)
      new_name = "#{name}_IDHMC#{ext}"
      idhmc_file = File.join(@emop_path_prefix, File.dirname(@page_result.ocr_text_path), new_name)
      allow(File).to receive('exist?').with(idhmc_file).and_return(true)
      allow(File).to receive(:open).with(idhmc_file, 'r').and_return(@file)

      get :get_page_text, @params

      expect(json['page']).to eq(@page.pg_ref_number)
      expect(json['content']).to eq('ocr-text-output')
    end

    it "should send data" do
      @params[:download] = true

      get :get_page_text, @params

      expect(response.headers['Content-Disposition']).to eq("attachment; filename=\"#{File.basename(@page_result.ocr_text_path)}\"")
      expect(response.headers['Content-Type']).to eq('text/plain')
    end
  end

 describe "GET get_page_hocr" do
    before(:each) do
      @print_font = create(:print_font)
      @work = create(:work, print_font: @print_font)
      @page = @work.pages.first
      @batch_job = create(:batch_job)
      @job_queue = create(:job_queue, page: @page, work: @work, batch_job: @batch_job, status: JobStatus.done)
      @page_result = create(:page_result, page: @page, batch_job: @batch_job)

      @params = {
        id: @page_result.id,
      }
      # Mock directory storing OCR output
      @emop_path_prefix = Dir.mktmpdir
      allow(Rails.application.secrets).to receive(:emop_path_prefix) { @emop_path_prefix }
      # Mock text output
      xml_filename = File.join(@emop_path_prefix, @page_result.ocr_xml_path)
      @file = double('ocr-xml-output')
      allow(File).to receive(:open).with(xml_filename, 'r').and_return(@file)
      allow(@file).to receive(:read).and_return('ocr-xml-output')
      allow(ResultsController).to receive(:get_idhmc_page).with(@page_result.ocr_xml_path).and_return([xml_filename, 'ocr-xml-output'])
    end

    it "should respond successfully" do
      get :get_page_hocr, @params

      expect(response).to be_success
    end

    it "should respond with page result information" do
      get :get_page_hocr, @params

      expect(json['page']).to eq(@page.pg_ref_number)
      expect(json['content']).to eq('ocr-xml-output')
    end

    it "should respond with page result information for IDHMC page" do
      #TODO Move this logic into model
      ext = File.extname(@page_result.ocr_xml_path)
      name = File.basename(@page_result.ocr_xml_path, ext)
      new_name = "#{name}_IDHMC#{ext}"
      idhmc_file = File.join(@emop_path_prefix, File.dirname(@page_result.ocr_xml_path), new_name)
      allow(File).to receive('exist?').with(idhmc_file).and_return(true)
      allow(File).to receive(:open).with(idhmc_file, 'r').and_return(@file)

      get :get_page_hocr, @params

      expect(json['page']).to eq(@page.pg_ref_number)
      expect(json['content']).to eq('ocr-xml-output')
    end

    it "should send data" do
      @params[:download] = true

      get :get_page_hocr, @params

      expect(response.headers['Content-Disposition']).to eq("attachment; filename=\"#{File.basename(@page_result.ocr_xml_path)}\"")
      expect(response.headers['Content-Type']).to eq('text/xml')
    end
  end

  describe "GET get_page_image" do
    before(:each) do
      skip "Unable to mock ImageMagick"
      @print_font = create(:print_font)
      @work = create(:work, print_font: @print_font)
      @page = @work.pages.first

      @params = {
        work: @work.id,
        num: @page.pg_ref_number,
      }
      # Mock directory storing OCR output
      @emop_path_prefix = Dir.mktmpdir
      allow(Rails.application.secrets).to receive(:emop_path_prefix) { @emop_path_prefix }
    end

    it "should respond successfully" do
      get :get_page_image, @params

      expect(response).to be_success
    end

    it "should send valid data" do
      get :get_page_image, @params

      expect(response.headers['Content-Type']).to eq('image/png')
    end
  end

  describe "GET get_page_error" do
    before(:each) do
      @work = create(:work)
      @page = @work.pages.first
      @batch_job = create(:batch_job)
      @job_queue = create(:job_queue, page: @page, work: @work, batch_job: @batch_job, status: JobStatus.failed, results: "ERROR")

      @params = {
        page: @page.id,
        batch: @batch_job.id,
      }
    end

    it "should respond successfully" do
      get :get_page_error, @params

      expect(response).to be_success
    end

    it "should respond with a jobs results" do
      get :get_page_error, @params

      expect(json).to match(
        'page' => @page.pg_ref_number,
        'error' => @job_queue.results,
      )
    end
  end

  describe "POST reschedule" do
    before(:each) do
      @batch_job = create(:batch_job)
      @work = create(:work)
      @page = create(:page, work: @work)
      @job_queue = create(:job_queue, batch_job: @batch_job, page: @page, work: @work, status: JobStatus.failed, proc_id: '00001', results: 'error')
      @page_result = create(:page_result, batch_job: @batch_job, page: @page)
      @postproc_page = create(:postproc_page, batch_job: @batch_job, page: @page)
      @params = {
        pages: [@page.id],
        batch: @batch_job.id,
      }
    end

    it "should respond successfully" do
      post :reschedule, @params

      expect(response).to be_success
    end

    it "should reschedule a batch job" do
      post :reschedule, @params

      expect { PageResult.find(@page_result.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect { PostprocPage.find(@postproc_page.id) }.to raise_error(ActiveRecord::RecordNotFound)
      job_queue = JobQueue.find(@job_queue.id)
      expect(job_queue.status).to eq(JobStatus.not_started)
      expect(job_queue.proc_id).to be_nil
      expect(job_queue.results).to be_nil
    end
  end

  describe "POST create_batch" do
    before(:each) do
      @job_type = JobType.find_by(name: 'OCR')
      @ocr_engine = OcrEngine.find_by(name: 'Tesseract')
      @font = create(:font)
      @pages = create_list(:page, 2)
      @page_ids = @pages.map(&:id)

      @params = {
        name: 'TEST',
        type_id: @job_type.id,
        engine_id: @ocr_engine.id,
        font_id: @font.id,
        #Can't use params in params
        #params: '',
        notes: '',
        json: {pages: @page_ids}.to_json,
      }
    end

    it "should respond successfully" do
      post :create_batch, @params

      expect(response).to be_success
      expect(response.body).to_not be_nil
    end

    it "should respond with batch job ID" do
      post :create_batch, @params

      batch_job = BatchJob.find_by(name: @params[:name])
      expect(response.body).to eq(batch_job.id.to_s)
    end

    it "should create batch of selected pages" do
      post :create_batch, @params

      batch_job = BatchJob.find_by(name: @params[:name])
      expect(batch_job.job_type).to eq(@job_type)
      expect(batch_job.ocr_engine).to eq(@ocr_engine)
      expect(batch_job.font).to eq(@font)
    end

    it "should create job queue for each page" do
      post :create_batch, @params

      job_queues = JobQueue.all
      batch_job = BatchJob.find_by(name: @params[:name])
      expect(job_queues.size).to eq(@pages.count)
      job_queues.each do |job_queue|
        expect(job_queue.batch_job).to eq(batch_job)
      end
    end
  end
end
