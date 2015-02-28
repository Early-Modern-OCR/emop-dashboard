require 'rails_helper'

RSpec.describe JobStatus, :type => :model do
  let(:job_status) { JobStatus.first }

  it "is valid" do
    expect(job_status).to be_valid
  end

  describe 'self.not_started' do
    it 'returns Not Started JobStatus' do
      expect(JobStatus.not_started.name).to eq('Not Started')
    end
  end

  describe 'self.processing' do
    it 'returns Processing JobStatus' do
      expect(JobStatus.processing.name).to eq('Processing')
    end
  end

  describe 'self.pending_postprocess' do
    it 'returns Pending Postprocess JobStatus' do
      expect(JobStatus.pending_postprocess.name).to eq('Pending Postprocess')
    end
  end

  describe 'self.done' do
    it 'returns Done JobStatus' do
      expect(JobStatus.done.name).to eq('Done')
    end
  end

  describe 'self.failed' do
    it 'returns Failed JobStatus' do
      expect(JobStatus.failed.name).to eq('Failed')
    end
  end

  describe 'self.ingest_failed' do
    it 'returns Ingest Failed JobStatus' do
      expect(JobStatus.ingest_failed.name).to eq('Ingest Failed')
    end
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
