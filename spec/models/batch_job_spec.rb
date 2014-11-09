require 'rails_helper'

RSpec.describe BatchJob, :type => :model do
  let(:batch_job) { create(:batch_job) }

  it "is valid" do
    expect(batch_job).to be_valid
  end

  describe "to_builder" do
    it "has valid to_builder - v1" do
      json = batch_job.to_builder('v1').attributes!
      expect(json).to match(
        'id'          => batch_job.id,
        'name'        => batch_job.name,
        'parameters'  => batch_job.parameters,
        'notes'       => batch_job.notes,
        'job_type'    => include(batch_job.job_type.to_builder.attributes!),
        'ocr_engine'  => include(batch_job.ocr_engine.to_builder.attributes!),
        'font'        => include(batch_job.font.to_builder.attributes!),
      )
    end
  end
end
