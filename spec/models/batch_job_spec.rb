require 'rails_helper'

RSpec.describe BatchJob, :type => :model do
  it "is valid" do
    batch_job = build(:batch_job)
    expect(batch_job).to be_valid
  end
end
