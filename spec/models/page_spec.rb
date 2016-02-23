require 'rails_helper'

RSpec.describe Page, :type => :model do
  let(:page) { create(:page) }

  it "is valid" do
    expect(page).to be_valid
  end

  describe 'ActiveModel validations' do
    it { expect(page).to validate_presence_of(:pg_ref_number) }
    it { expect(page).to validate_presence_of(:pg_image_path) }
    it { expect(page).to validate_presence_of(:work) }
    it { expect(page).to validate_uniqueness_of(:pg_ref_number).scoped_to(:pg_work_id) }
    it { expect(page).to validate_uniqueness_of(:pg_image_path) }
  end

  describe "to_builder" do
    it "has valid to_builder - v1" do
      json = page.to_builder('v1').attributes!

      expect(json).to match(
        'id' => page.id,
        'pg_ref_number' => page.pg_ref_number,
        'pg_ground_truth_file' => page.pg_ground_truth_file,
        'work' => include(page.work.to_builder.attributes!),
        'pg_gale_ocr_file' => page.pg_gale_ocr_file,
        'pg_image_path' => page.pg_image_path,
      )
    end
  end
end
