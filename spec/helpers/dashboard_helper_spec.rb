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

  describe "#collection_filter_options" do
    it 'returns options for select' do
      ecco = create(:works_collection, name: 'ECCO')
      eebo = create(:works_collection, name: 'EEBO')
      result = helper.collection_filter_options(nil)
      expected = [
        '<option value="">All</option>',
        "<option value=\"#{ecco.id}\">ECCO</option>",
        "<option value=\"#{eebo.id}\">EEBO</option>",
      ]
      expect(result.split(/\n/)).to eq(expected)
    end

    it 'returns options for select - selected set' do
      ecco = create(:works_collection, name: 'ECCO')
      eebo = create(:works_collection, name: 'EEBO')
      result = helper.collection_filter_options(ecco.id)
      expected = [
        '<option value="">All</option>',
        "<option selected=\"selected\" value=\"#{ecco.id}\">ECCO</option>",
        "<option value=\"#{eebo.id}\">EEBO</option>",
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

  describe '#work_checkbox' do
    before(:each) do
      @batch_job = create(:batch_job)
      @work = create(:work)
      page = create(:page, work: @work)
      create(:job_queue, batch_job: @batch_job, page: page, work: @work)
    end

    it 'creates checkbox for work and batch' do
      expect(helper.work_checkbox(@work, @batch_job)).to have_tag('input', with: {
        class: 'sel-cb',
        id: "sel-#{@work.id}-#{@batch_job.id}",
        name: "sel-#{@work.id}-#{@batch_job.id}",
        type: 'checkbox',
      })
    end

    it 'creates checkbox for work with no batch_job' do
      work = create(:work)
      expect(helper.work_checkbox(work, nil)).to have_tag('input', with: {
        class: 'sel-cb',
        id: "sel-#{work.id}-0",
        name: "sel-#{work.id}-0",
        type: 'checkbox',
      })
    end
  end

  describe '#work_detail_link' do
    before(:each) do
      @batch_job = create(:batch_job)
      @work = create(:work)
      page = create(:page, work: @work)
      create(:job_queue, batch_job: @batch_job, page: page, work: @work)
    end

    it 'creates div link for work and batch_job' do
      expected_href = "/results?batch=#{@batch_job.id}&work=#{@work.id}"
      expect(helper.work_detail_link(@work, @batch_job)).to have_tag('a', with: { href: expected_href }) do
        with_tag 'div', with: { class: 'detail-link', title: 'View pages' }
      end
    end

    it 'creates div link for work with no batch_job' do
      work = create(:work)
      expected_href = "/results?work=#{work.id}"
      expect(helper.work_detail_link(work, nil)).to have_tag('a', with: { href: expected_href }) do
        with_tag 'div', with: { class: 'detail-link', title: 'View pages' }
      end
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

        expect(helper.work_status(@work, @batch_job)).to eq(html)
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

        expect(helper.work_status(@work, @batch_job)).to eq(html)
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

        expect(helper.work_status(@work, @batch_job)).to eq(html)
      end
    end

    context 'when no job_queues exist' do
      before(:each) do
        @work = create(:work)
      end

      it 'should return status counts of 0' do
        html = "<a class='status-text scheduled'>0</a>-" \
               "<a class='status-text processing'>0</a>-" \
               "<a class='status-text success'>0</a>-" \
               "<a class='status-text failed'>0</a>"

        expect(helper.work_status(@work, nil)).to eq(html)
      end
    end
  end

  describe '#ocr_date' do
    before(:each) do
      @batch_job = create(:batch_job)
      @work = create(:work)
      @time_now = Time.parse("Nov 09 2014 00:00Z")
      page = create(:page, work: @work)
      create(:page_result, page: page, batch_job: @batch_job, ocr_completed: @time_now)
    end

    it 'returns formatted date' do
      expect(helper.ocr_date(@work)).to eq('11/09/2014 00:00')
    end

    it 'returns nothing when page_results do not exist' do
      work = create(:work)
      expect(helper.ocr_date(work)).to eq('')
    end
  end

  describe '#ocr_engine' do
    before(:each) do
      @ocr_engine = OcrEngine.find_by(name: 'Tesseract')
      @batch_job = create(:batch_job, ocr_engine: @ocr_engine)
      @work = create(:work)
      page = create(:page, work: @work)
      create(:job_queue, batch_job: @batch_job, page: page, work: @work)
    end

    it 'returns ocr engine name' do
      expect(helper.ocr_engine(@work, @batch_job)).to eq('Tesseract')
    end

    it 'returns nothing when results do not exist' do
      work = create(:work)
      expect(helper.ocr_engine(work, nil)).to eq('')
    end
  end

  describe '#ocr_batch' do
    before(:each) do
      @batch_job = create(:batch_job)
      @work = create(:work)
      page = create(:page, work: @work)
      create(:job_queue, batch_job: @batch_job, page: page, work: @work)
    end

    it 'returns batch ID and name' do
      expect(helper.ocr_batch(@work, @batch_job)).to have_tag('span', text: "#{@batch_job.id}: #{@batch_job.name}",
        with: { class: 'batch-name', id: "batch-#{@batch_job.id}" })
    end

    it 'returns nothing when results do not exist' do
      work = create(:work)
      expect(helper.ocr_batch(work, nil)).to eq('')
    end
  end

  describe '#accuracy_links' do
    before(:each) do
      @batch_job = create(:batch_job)
      @work = create(:work)
      page = create(:page, work: @work)
      @page_result = create(:page_result, page: page, batch_job: @batch_job)
      @url = "/results?batch=#{@batch_job.id}&work=#{@work.id}"
    end

    it 'returns N/A when results do not exist' do
      work = create(:work)
      expect(helper.accuracy_links(work, 'juxta_accuracy')).to eq('N/A')
    end

    it 'returns N/A when juxta results do not exist' do
      @page_result.update!(juxta_change_index: nil)
      expect(helper.accuracy_links(@work, 'juxta_accuracy')).to eq('N/A')
    end

    it 'returns returns html for low value' do
      @page_result.update!(juxta_change_index: 0.01)
      expect(helper.accuracy_links(@work, 'juxta_accuracy')).to have_tag('a', text: '0.010', with: {
        href: @url,
        class: 'bad-cell',
        title: 'View page results',
      })
    end

    it 'returns returns html for moderate value' do
      @page_result.update!(juxta_change_index: 0.7)
      expect(helper.accuracy_links(@work, 'juxta_accuracy')).to have_tag('a', text: '0.700', with: {
        href: @url,
        class: 'warn-cell',
        title: 'View page results',
      })
    end

    it 'returns returns html for high value' do
      @page_result.update!(juxta_change_index: 1.0)
      expect(helper.accuracy_links(@work, 'juxta_accuracy')).to have_tag('a', text: '1.000', with: {
        href: @url,
        #class: '', #TODO: Causes nokogiri errors
        title: 'View page results',
      })
    end
  end
end
