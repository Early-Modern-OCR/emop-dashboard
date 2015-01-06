require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe "#page_status_icon" do
    it "returns scheduled div when status not started" do
      job_queue = create(:job_queue, status: JobStatus.not_started)
      expect(helper.page_status_icon(job_queue)).to eq("<div class='status-icon scheduled' title='OCR job scheduled'></div>")
    end

    it "returns scheduled div when status processing" do
      job_queue = create(:job_queue, status: JobStatus.processing)
      expect(helper.page_status_icon(job_queue)).to eq("<div class='status-icon processing' title='OCR job processing'></div>")
    end

    it "returns failed div" do
      job_queue = create(:job_queue, status: JobStatus.failed)
      expect(helper.page_status_icon(job_queue)).to eq("<div id='status-#{job_queue.batch_job.id}-#{job_queue.page.id}' class='status-icon error' title='OCR job failed'></div>")
    end

    it "returns success div" do
      job_queue = create(:job_queue, status: JobStatus.done)
      expect(helper.page_status_icon(job_queue)).to eq("<div class='status-icon success' title='Success'></div>")
    end

    it "returns untested div" do
      job_queue = nil
      expect(helper.page_status_icon(job_queue)).to eq("<div class='status-icon idle' title='Untested'></div>")
    end
  end

  describe "#work_status" do
    before(:each) do
      @batch_job = create(:batch_job)
      @work = create(:work)
    end

    context "when no job_queues exist" do
      it "should return all 0s" do
        html = "<a class='status-text scheduled'>0</a>-" \
               "<a class='status-text processing'>0</a>-" \
               "<a class='status-text success'>0</a>-" \
               "<a class='status-text failed'>0</a>"

        expect(helper.work_status(@batch_job.id, @work.id)).to eq(html)
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

        expect(helper.work_status(@batch_job.id, @work.id)).to eq(html)
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

        expect(helper.work_status(@batch_job.id, @work.id)).to eq(html)
      end
    end
  end
end
