require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe '#git_version_info' do
    let(:revision_file) { File.join(Rails.root, 'REVISION') }
    let(:version_file) { File.join(Rails.root, 'VERSION') }

    context 'when REVISION and VERSION exist' do
      it 'contains version and revision information' do
        allow(File).to receive(:exists?).with(revision_file).and_return(true)
        allow(File).to receive(:exists?).with(version_file).and_return(true)
        allow(File).to receive(:read).with(revision_file).and_return("0001\n")
        allow(File).to receive(:read).with(version_file).and_return("1.0.0\n")
        expect(helper.git_version_info).to eq('Version: 1.0.0 Revision: 0001')
      end
    end

    context 'when only REVISION exists' do
      it 'contains only revision information' do
        allow(File).to receive(:exists?).with(revision_file).and_return(true)
        allow(File).to receive(:exists?).with(version_file).and_return(false)
        allow(File).to receive(:read).with(revision_file).and_return("0001\n")
        expect(helper.git_version_info).to eq('Version: Unknown Revision: 0001')
      end
    end

    context 'when only VERSION exist' do
      it 'contains version and revision information' do
        allow(File).to receive(:exists?).with(revision_file).and_return(false)
        allow(File).to receive(:exists?).with(version_file).and_return(true)
        allow(File).to receive(:read).with(version_file).and_return("1.0.0\n")
        expect(helper.git_version_info).to eq('Version: 1.0.0 Revision: Unknown')
      end
    end
  end

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
