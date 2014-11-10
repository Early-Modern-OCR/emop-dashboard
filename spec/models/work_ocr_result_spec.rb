require 'rails_helper'

RSpec.describe WorkOcrResult, :type => :model do
  before(:each) do
    create(:batch_job)
    create(:page)
    create(:page_result)
  end
  let(:work_ocr_result) { WorkOcrResult.first }

  it "is valid" do
    expect(work_ocr_result).to be_valid
  end

  it "fail to save" do
    work_ocr_result.batch_name = "Foo"
    expect {
      work_ocr_result.save
    }.to raise_error(ActiveRecord::ReadOnlyRecord)
  end

  it "fail to destroy" do
    expect {
      work_ocr_result.destroy
    }.to raise_error(ActiveRecord::ReadOnlyRecord)
  end
end
