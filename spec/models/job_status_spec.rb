require 'rails_helper'

RSpec.describe JobStatus, :type => :model do
  it "is valid" do
    job_status = build(:job_status)
    expect(job_status).to be_valid
  end
end
