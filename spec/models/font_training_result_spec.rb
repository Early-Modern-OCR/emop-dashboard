require 'rails_helper'

RSpec.describe FontTrainingResult, :type => :model do
  let(:font_training_result) { create(:font_training_result) }

  it "is valid" do
    expect(font_training_result).to be_valid
  end

  describe 'ActiveModel validations' do
    it { expect(font_training_result).to validate_presence_of(:work) }
    it { expect(font_training_result).to validate_presence_of(:batch_job) }
    it { expect(font_training_result).to validate_uniqueness_of(:font_path).scoped_to(:work_id, :batch_job_id) }
    it { expect(font_training_result).to validate_uniqueness_of(:language_model_path).scoped_to(:work_id, :batch_job_id) }
    it { expect(font_training_result).to validate_uniqueness_of(:glyph_substitution_model_path).scoped_to(:work_id, :batch_job_id) }
  end

  describe "to_builder" do
    it "has valid to_builder - v2" do
      json = font_training_result.to_builder('v2').attributes!
      expect(json).to match(
      'id'                            => font_training_result.id,
      'work_id'                       => font_training_result.work_id,
      'batch_job_id'                  => font_training_result.batch_job_id,
      'font_path'                     => font_training_result.font_path,
      'language_model_path'           => font_training_result.language_model_path,
      'glyph_substitution_model_path' => font_training_result.glyph_substitution_model_path,
      )
    end
  end

end
