require 'rails_helper'

RSpec.describe BatchJob, :type => :model do
  let(:batch_job) { create(:batch_job) }

  it "is valid" do
    expect(batch_job).to be_valid
  end

  describe 'ActiveModel validations' do
    it { expect(batch_job).to validate_presence_of(:ocr_engine) }
    it { expect(batch_job).to validate_presence_of(:job_type) }
  end

  describe "dependent :destroy" do
    it "should destroy associated job_queues" do
      job_queue = create(:job_queue, batch_job: batch_job)
      expect(batch_job.job_queues.present?).to be true
      expect(JobQueue.find(job_queue.id)).to_not be_nil
      batch_job.destroy!
      expect { JobQueue.find(job_queue.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "should destroy associated page_results" do
      page_result = create(:page_result, batch_job: batch_job)
      expect(batch_job.page_results.present?).to be true
      expect(PageResult.find(page_result.id)).to_not be_nil
      batch_job.destroy!
      expect { PageResult.find(page_result.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "should destroy associated postproc_pages" do
      postproc_page = create(:postproc_page, batch_job: batch_job)
      expect(batch_job.postproc_pages.present?).to be true
      expect(PostprocPage.find(postproc_page.id)).to_not be_nil
      batch_job.destroy!
      expect { PostprocPage.find(postproc_page.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'font_training scope' do
    it 'should return only Font Training types' do
      create_list(:batch_job, 3, job_type: JobType.find_by(name: 'OCR'))
      create_list(:batch_job, 2, job_type: JobType.find_by(name: 'Font Training'))
      expect(BatchJob.font_training.count).to eq(2)
    end
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

    it "has valid to_builder - v2" do
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
