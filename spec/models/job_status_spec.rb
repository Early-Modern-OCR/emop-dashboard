require 'rails_helper'

RSpec.describe JobStatus, :type => :model do
  let(:job_status) { JobStatus.first }

  it "is valid" do
    expect(job_status).to be_valid
  end

  describe "to_builder" do
    it "has valid to_builder - v1" do
      json = job_status.to_builder('v1').attributes!

      expect(json).to match(
        'id'    => job_status.id,
        'name'  => job_status.name,
      )
    end
  end
end
