require 'rails_helper'

RSpec.describe DashboardHelper do
  describe "#gt_filter_options" do
    it 'returns options for select' do
      result = helper.gt_filter_options(nil)
      expected = [
        '<option value="">All</option>',
        '<option value="with_gt">With GT</option>',
        '<option value="without_gt">Without GT</option>',
      ]
      expect(result.split(/\n/)).to eq(expected)
    end

    it 'returns options for select - selected set' do
      result = helper.gt_filter_options('with_gt')
      expected = [
        '<option value="">All</option>',
        '<option selected="selected" value="with_gt">With GT</option>',
        '<option value="without_gt">Without GT</option>',
      ]
      expect(result.split(/\n/)).to eq(expected)
    end
  end

  describe "#dataset_filter_options" do
    it 'returns options for select' do
      result = helper.dataset_filter_options(nil)
      expected = [
        '<option value="">All</option>',
        '<option value="ECCO">ECCO</option>',
        '<option value="EEBO">EEBO</option>',
      ]
      expect(result.split(/\n/)).to eq(expected)
    end

    it 'returns options for select - selected set' do
      result = helper.dataset_filter_options('ECCO')
      expected = [
        '<option value="">All</option>',
        '<option selected="selected" value="ECCO">ECCO</option>',
        '<option value="EEBO">EEBO</option>',
      ]
      expect(result.split(/\n/)).to eq(expected)
    end
  end

  describe "#dataset_filter_options" do
    it 'returns options for select' do
      result = helper.dataset_filter_options(nil)
      expected = [
        '<option value="">All</option>',
        '<option value="ECCO">ECCO</option>',
        '<option value="EEBO">EEBO</option>',
      ]
      expect(result.split(/\n/)).to eq(expected)
    end

    it 'returns options for select - selected set' do
      result = helper.dataset_filter_options('ECCO')
      expected = [
        '<option value="">All</option>',
        '<option selected="selected" value="ECCO">ECCO</option>',
        '<option value="EEBO">EEBO</option>',
      ]
      expect(result.split(/\n/)).to eq(expected)
    end
  end

  describe "#ocr_filter_options" do
    it 'returns options for select' do
      result = helper.ocr_filter_options(nil)
      expected = [
        '<option value="">All</option>',
        '<option value="ocr_none">No OCR</option>',
        '<option value="ocr_sched">OCR Scheduled</option>',
        '<option value="ocr_done">OCR Complete</option>',
        '<option value="ocr_ingest">OCR Ingested</option>',
        '<option value="ocr_error">OCR Errors</option>',
        '<option value="ocr_ingest_error">OCR Ingest Errors</option>',
      ]
      expect(result.split(/\n/)).to eq(expected)
    end

    it 'returns options for select - selected set' do
      result = helper.ocr_filter_options('ocr_error')
      expected = [
        '<option value="">All</option>',
        '<option value="ocr_none">No OCR</option>',
        '<option value="ocr_sched">OCR Scheduled</option>',
        '<option value="ocr_done">OCR Complete</option>',
        '<option value="ocr_ingest">OCR Ingested</option>',
        '<option selected="selected" value="ocr_error">OCR Errors</option>',
        '<option value="ocr_ingest_error">OCR Ingest Errors</option>',
      ]
      expect(result.split(/\n/)).to eq(expected)
    end
  end

  describe "#batch_filter_options" do
    before(:each) do
      @batch_jobs = create_list(:batch_job, 2)
    end

    it 'returns options for select' do
      result = helper.batch_filter_options(nil)
      expected = [
        '<option value="">All</option>',
      ]
      @batch_jobs.each do |batch_job|
        expected << "<option value=\"#{batch_job.id}\">#{batch_job.name}</option>"
      end
      expect(result.split(/\n/)).to eq(expected)
    end

    it 'returns options for select - selected set' do
      result = helper.batch_filter_options(@batch_jobs.first.id)
      expected = [
        '<option value="">All</option>',
      ]
      @batch_jobs.each do |batch_job|
        if batch_job.id == @batch_jobs.first.id
          selected = ' selected="selected"'
        else
          selected = ''
        end
        expected << "<option#{selected} value=\"#{batch_job.id}\">#{batch_job.name}</option>"
      end
      expect(result.split(/\n/)).to eq(expected)
    end
  end

  describe "#print_font_filter_options" do
    before(:each) do
      @pfonts = create_list(:print_font, 2)
    end

    it 'returns options for select' do
      result = helper.print_font_filter_options(nil)
      expected = [
        '<option value="">All</option>',
      ]
      @pfonts.each do |pf|
        expected << "<option value=\"#{pf.id}\">#{pf.name}</option>"
      end
      expect(result.split(/\n/)).to eq(expected)
    end

    it 'returns options for select - selected set' do
      result = helper.print_font_filter_options(@pfonts.first.id)
      expected = [
        '<option value="">All</option>',
      ]
      @pfonts.each do |pf|
        if pf.id == @pfonts.first.id
          selected = ' selected="selected"'
        else
          selected = ''
        end
        expected << "<option#{selected} value=\"#{pf.id}\">#{pf.name}</option>"
      end
      expect(result.split(/\n/)).to eq(expected)
    end
  end

  describe "#work_status" do
    before(:each) do
      @batch_job = create(:batch_job)
      @work = create(:work)
      page = create(:page, work: @work)
      create(:page_result, page: page, batch_job: @batch_job)
    end

    context "when no job_queues exist" do
      it "should return all 0s" do
        html = "<a class='status-text scheduled'>0</a>-" \
               "<a class='status-text processing'>0</a>-" \
               "<a class='status-text success'>0</a>-" \
               "<a class='status-text failed'>0</a>"

        expect(helper.work_status(@work)).to eq(html)
      end
    end

    context "when job_queues exist" do
      before(:each) do
        @scheduled = create_list(:job_queue, 5, status: JobStatus.not_started, batch_job: @batch_job, work: @work)
        @processing = create_list(:job_queue, 10, status: JobStatus.processing, batch_job: @batch_job, work: @work)
        @success = create_list(:job_queue, 15, status: JobStatus.done, batch_job: @batch_job, work: @work)
      end

      it "should return status counts" do
        html = "<a class='status-text scheduled'>#{@scheduled.size}</a>-" \
               "<a class='status-text processing'>#{@processing.size}</a>-" \
               "<a class='status-text success'>#{@success.size}</a>-" \
               "<a class='status-text failed'>0</a>"

        expect(helper.work_status(@work)).to eq(html)
      end
    end

    context "when job_queues have failures" do
      before(:each) do
        @failed = create_list(:job_queue, 5, status: JobStatus.failed, batch_job: @batch_job, work: @work)
      end

      it "should return status counts" do
        html = "<a class='status-text scheduled'>0</a>-" \
               "<a class='status-text processing'>0</a>-" \
               "<a class='status-text success'>0</a>-" \
               "<a id='status-#{@batch_job.id}-#{@work.id}' class='status-text error'>#{@failed.size}</a>"

        expect(helper.work_status(@work)).to eq(html)
      end
    end
  end
end
