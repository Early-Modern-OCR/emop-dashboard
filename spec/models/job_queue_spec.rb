require 'rails_helper'

RSpec.describe JobQueue, :type => :model do
  let(:job_queue) { create(:job_queue) }

  it "is valid" do
    expect(job_queue).to be_valid
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
