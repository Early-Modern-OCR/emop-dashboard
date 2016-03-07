require 'rails_helper'

RSpec.describe FontTrainingResult, :type => :model do
  let(:font_training_result) { create(:font_training_result) }

  it "is valid" do
    expect(font_training_result).to be_valid
  end

  describe 'ActiveModel validations' do
    it { expect(font_training_result).to validate_presence_of(:path) }
    it { expect(font_training_result).to validate_presence_of(:work) }
    it { expect(font_training_result).to validate_presence_of(:batch_job) }
    it { expect(font_training_result).to validate_uniqueness_of(:path).scoped_to(:work_id, :batch_job_id) }
  end

  describe "to_builder" do
    it "has valid to_builder - v2" do
      json = font_training_result.to_builder('v2').attributes!
      expect(json).to match(
      'id'            => font_training_result.id,
      'work_id'       => font_training_result.work_id,
      'batch_job_id'  => font_training_result.batch_job_id,
      'path'          => font_training_result.path,
      )
    end
  end

end
