require 'rails_helper'

RSpec.describe BatchJob, :type => :model do
  let(:batch_job) { create(:batch_job) }

  it "is valid" do
    expect(batch_job).to be_valid
  end

  describe "set_defaults" do
    let(:batch_job) { BatchJob.new }

    it "has default ocr_engine" do
      ocr_engine = OcrEngine.find_by_name('Tesseract')
      expect(batch_job.ocr_engine.id).to eq(ocr_engine.id)
    end

    it "has default job_type" do
      job_type = JobType.find_by_name('OCR')
      expect(batch_job.job_type.id).to eq(job_type.id)
    end
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
