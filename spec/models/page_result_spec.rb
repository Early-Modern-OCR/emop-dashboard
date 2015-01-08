require 'rails_helper'

RSpec.describe PageResult, :type => :model do
  let(:page_result) { build(:page_result) }

  it "is valid" do
    expect(page_result).to be_valid
  end

  it 'should be unique' do
    attributes = {
      page: create(:page),
      batch_job: create(:batch_job),
    }

    @page_result = PageResult.create!(attributes)
    expect(@page_result).to be_valid

    @page_result = PageResult.new(attributes)
    expect(@page_result).not_to be_valid
    expect(@page_result.errors[:page]).to include("has already been taken")
  end

  describe "to_builder" do
    it "has valid to_builder - v1" do
      json = page_result.to_builder('v1').attributes!
      expect(json).to match(
        'id'                  => page_result.id,
        'ocr_text_path'       => page_result.ocr_text_path,
        'ocr_xml_path'        => page_result.ocr_xml_path,
        'corr_ocr_text_path'  => page_result.corr_ocr_text_path,
        'corr_ocr_xml_path'   => page_result.corr_ocr_xml_path,
        'ocr_completed'       => page_result.ocr_completed,
        'juxta_change_index'  => page_result.juxta_change_index,
        'alt_change_index'    => page_result.alt_change_index,
        'page'                => include(page_result.page.to_builder.attributes!),
        'batch_job'           => include(page_result.batch_job.to_builder.attributes!),
      )
    end
  end
end
