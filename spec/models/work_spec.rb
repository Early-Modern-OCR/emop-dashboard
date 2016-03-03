require 'rails_helper'

RSpec.describe Work, :type => :model do
  let(:work) { create(:work) }

  it "is valid" do
    expect(work).to be_valid
  end

  describe 'ActiveModel validations' do
    it { expect(work).to validate_uniqueness_of(:wks_title) }
  end

  describe 'isECCO?' do
    it 'should be true when assigned ECCO collection is present' do
      work.collection = create(:works_collection, name: 'ECCO')
      expect(work.isECCO?).to be true
    end

    it 'should be false when collection is not ECCO' do
      work.collection = create(:works_collection, name: 'foo')
      expect(work.isECCO?).to be false
    end

    it 'should be false when collection is nil' do
      work.collection = nil
      expect(work.isECCO?).to be false
    end
  end

  describe "#ground_truth" do
    it 'should scope with_gt' do
      expect(Work).to receive(:with_gt)
      Work.ground_truth('with_gt')
    end

    it 'should scope without_gt' do
      expect(Work).to receive(:without_gt)
      Work.ground_truth('without_gt')
    end
  end

  describe "to_builder" do
    it "has valid to_builder - v1" do
      json = work.to_builder('v1').attributes!

      expect(json).to match(
        'id' => work.id,
        'wks_tcp_number' => work.wks_gt_number,
        'wks_estc_number' => work.wks_estc_number,
        'wks_bib_name' => work.wks_coll_name,
        'wks_tcp_bibno' => work.wks_tcp_bibno,
        'wks_marc_record' => work.wks_marc_record,
        'wks_eebo_citation_id' => work.wks_eebo_citation_id,
        'wks_eebo_directory' => work.wks_doc_directory,
        'wks_ecco_number' => work.wks_ecco_number,
        'wks_book_id' => work.wks_book_id,
        'wks_author' => work.wks_author,
        'wks_publisher' => work.wks_printer,
        'wks_word_count' => work.wks_word_count,
        'wks_title' => work.wks_title,
        'wks_eebo_image_id' => work.wks_eebo_image_id,
        'wks_eebo_url' => work.wks_eebo_url,
        'wks_pub_date' => work.wks_pub_date,
        'wks_ecco_uncorrected_gale_ocr_path' => work.wks_ecco_uncorrected_gale_ocr_path,
        'wks_ecco_corrected_xml_path' => work.wks_corrected_xml_path,
        'wks_ecco_corrected_text_path' => work.wks_corrected_text_path,
        'wks_ecco_directory' => work.wks_ecco_directory,
        'wks_ecco_gale_ocr_xml_path' => work.wks_ecco_gale_ocr_xml_path,
        'wks_organizational_unit' => work.wks_organizational_unit,
        'wks_primary_print_font' => work.wks_primary_print_font,
        'wks_last_trawled' => work.wks_last_trawled,
      )
    end
  end
end
