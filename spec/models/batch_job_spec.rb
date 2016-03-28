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

  describe "font_training?" do
    it "should be true if Font Training" do
      batch_job = create(:batch_job, job_type: JobType.find_by_name('Font Training'))
      expect(batch_job.font_training?).to be true
    end

    it "should be false if not Font Training" do
      batch_job = create(:batch_job, job_type: JobType.find_by_name('OCR'))
      expect(batch_job.font_training?).to be false
    end
  end

  describe 'clone_as_ocr_batch_job!' do
    before(:each) do
      @work1 = create(:work)
      @work2 = create(:work)
      @pages1 = create_list(:page, 15, work: @work1)
      @pages2 = create_list(:page, 25, work: @work2)

      @batch_job = create(:batch_job, ocr_engine: OcrEngine.find_by_name('Ocular'), job_type: JobType.find_by_name('Font Training'))
      @job_queues = []
      (@pages1[0..9] + @pages2[0..9]).each do |page|
        @job_queues << create(:job_queue, page: page, work: page.work, batch_job: @batch_job, status: JobStatus.not_started)
      end
    end

    it 'should clone to OCR batch job' do
      new_batch_job = @batch_job.clone_as_ocr_batch_job!
      expect(new_batch_job.job_type.name).to eq('OCR')
      expect(new_batch_job.ocr_engine).to eq(@batch_job.ocr_engine)
      expect(new_batch_job.font_training_result_batch_job_id).to eq(@batch_job.id)
    end

    it 'should create batch with all pages' do
      expect(@job_queues.size).to eq(20)
      expect {
        @batch_job.clone_as_ocr_batch_job!
      }.to change(JobQueue, :count).by(@work1.pages.count + @work2.pages.count)
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
