require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe "#page_status_icon" do
    it "returns scheduled div when status not started" do
      job_queue = create(:job_queue, status: JobStatus.not_started)
      expect(helper.page_status_icon(job_queue)).to have_tag('div', with: {
        class: 'status-icon scheduled',
        title: 'OCR job scheduled',
        'data-id' => JobStatus.not_started.id
      })
    end

    it "returns scheduled div when status processing" do
      job_queue = create(:job_queue, status: JobStatus.processing)
      expect(helper.page_status_icon(job_queue)).to have_tag('div', with: {
        class: 'status-icon processing',
        title: 'OCR job processing',
        'data-id' => JobStatus.processing.id
      })
    end

    it "returns failed div" do
      job_queue = create(:job_queue, status: JobStatus.failed)
      expect(helper.page_status_icon(job_queue)).to have_tag('div', with: {
        id: "status-#{job_queue.batch_job.id}-#{job_queue.page.id}",
        class: 'status-icon error',
        title: 'OCR job failed',
        'data-id' => JobStatus.failed.id
      })
    end

    it "returns success div" do
      job_queue = create(:job_queue, status: JobStatus.done)
      expect(helper.page_status_icon(job_queue)).to have_tag('div', with: {
        class: 'status-icon success',
        title: 'Success',
        'data-id' => JobStatus.done.id
      })
    end

    it "returns untested div" do
      job_queue = nil
      expect(helper.page_status_icon(job_queue)).to have_tag('div', with: {
        class: 'status-icon idle',
        title: 'Untested',
        'data-id' => 0
      })
    end
  end
end
