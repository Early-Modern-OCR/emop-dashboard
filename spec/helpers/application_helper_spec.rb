require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe "#page_status_icon" do
    it "returns scheduled div when status not started" do
      job_queue = create(:job_queue, status: JobStatus.not_started)
      expect(helper.page_status_icon(job_queue)).to eq("<div class='status-icon scheduled' title='OCR job scheduled'></div>")
    end

    it "returns scheduled div when status processing" do
      job_queue = create(:job_queue, status: JobStatus.processing)
      expect(helper.page_status_icon(job_queue)).to eq("<div class='status-icon scheduled' title='OCR job scheduled'></div>")
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
end
