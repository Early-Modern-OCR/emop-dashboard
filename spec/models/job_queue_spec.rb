require 'rails_helper'

RSpec.describe JobQueue, :type => :model do
  it "is valid" do
    job_queue = build(:job_queue)
    expect(job_queue).to be_valid
  end
end
