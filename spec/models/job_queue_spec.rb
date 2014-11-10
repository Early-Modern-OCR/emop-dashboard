require 'rails_helper'

RSpec.describe JobQueue, :type => :model do
  let(:job_queue) { create(:job_queue) }

  it "is valid" do
    expect(job_queue).to be_valid
  end

  describe "set_defaults" do
    let(:job_queue) { JobQueue.new }

    it "has default status" do
      expect(job_queue.status).not_to be_nil
    end
  end

  describe "#generate_proc_id" do
    it "should generate proc_id" do
      @time_now = Time.parse("Nov 09 2014")
      allow(Time).to receive(:now).and_return(@time_now)

      generated_proc_id = JobQueue.generate_proc_id
      expect(generated_proc_id).to eq('20141109000000000')
    end
  end

  describe "#status_summary" do
    it "should generate status counts" do
      create_list(:job_queue, 2, status: JobStatus.not_started)
      create_list(:job_queue, 3, status: JobStatus.processing)
      create_list(:job_queue, 5, status: JobStatus.done)
      create_list(:job_queue, 8, status: JobStatus.failed)
      create_list(:job_queue, 10, status: JobStatus.ingest_failed)

      summary = JobQueue.status_summary
      expect(summary[:pending]).to eq(2)
      expect(summary[:running]).to eq(3)
      expect(summary[:postprocess]).to eq(0)
      expect(summary[:done]).to eq(5)
      expect(summary[:failed]).to eq(8)
      expect(summary[:ingestfailed]).to eq(10)
      expect(summary[:total]).to eq(28)
    end
  end

  describe "to_builder" do
    it "has valid to_builder - v1" do
      json = job_queue.to_builder('v1').attributes!

      expect(json).to match(
        'id'        => job_queue.id,
        'tries'     => job_queue.tries,
        'results'   => job_queue.results,
        'status'    => include(job_queue.status.to_builder.attributes!),
        'batch_job' => include(job_queue.batch_job.to_builder.attributes!),
        'page'      => include(job_queue.page.to_builder.attributes!),
        'work'      => include(job_queue.work.to_builder.attributes!),
        'proc_id'   => job_queue.proc_id,
      )
    end
  end
end
