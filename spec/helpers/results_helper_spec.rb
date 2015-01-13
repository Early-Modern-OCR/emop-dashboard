require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe "#page_image" do
    it "returns view page image link" do
      page = create(:page)
      expected_link = "/results/#{page.pg_work_id}/page/#{page.pg_ref_number}"
      expect(helper.page_image(page)).to have_tag('a', with: { href: expected_link }) do
        with_tag 'div', with: { title: 'View page image', class: 'page-view' }
      end
    end
  end

  describe '#ocr_output_div_by_type' do
    before(:each) do
      @page_result = create(:page_result)
    end

    context 'when type is text' do
      it "returns view OCR text HTML" do
        expect(helper.ocr_output_div_by_type(@page_result, 'text')).to have_tag('div', with: {
          title: 'View OCR text output',
          class: 'ocr-txt',
          'data-source' => "/results/#{@page_result.id}/text",
          'data-id' => @page_result.id
        })
      end

      it "returns disabled HTML" do
        expect(helper.ocr_output_div_by_type(nil, 'text')).to have_tag('div', with: {
          title: 'View OCR text output',
          class: 'ocr-txt disabled'
        })
      end
    end

    context 'when type is hocr' do
      it "returns view OCR text HTML" do
        expect(helper.ocr_output_div_by_type(@page_result, 'hocr')).to have_tag('div', with: {
          title: 'View hOCR output',
          class: 'ocr-hocr',
          'data-source' => "/results/#{@page_result.id}/hocr",
          'data-id' => @page_result.id
        })
      end

      it "returns disabled HTML" do
        expect(helper.ocr_output_div_by_type(nil, 'hocr')).to have_tag('div', with: {
          title: 'View hOCR output',
          class: 'ocr-hocr disabled'
        })
      end
    end
  end

  describe "#detail_link" do
    before(:each) do
      @page_result = create(:page_result)
    end

    it "returns GT comparison link" do
      expected_href = "/juxta?batch=#{@page_result.batch_id}&" \
                      "page=#{@page_result.page.pg_ref_number}&" \
                      "result=#{@page_result.id}&" \
                      "work=#{@page_result.page.pg_work_id}"
      expected_title = 'View side-by-side comparison with GT'
      expect(helper.detail_link(@page_result)).to have_tag('a', with: { href: expected_href, title: expected_title }) do
        with_tag 'div', with: { class: 'juxta-link' }
      end
    end

    it "returns no link when page_result is nil" do
      expect(helper.detail_link(nil)).to have_tag('div', with: { class: 'juxta-link disabled' })
    end
  end

  describe "#page_result_data" do
    before(:each) do
      @page_result = create(:page_result)
    end

    it "returns juxta_change_index" do
      expect(helper.page_result_data(@page_result, 'juxta_change_index')).to eq(@page_result.juxta_change_index)
    end

    it "returns - when page_result is nil" do
      expect(helper.page_result_data(nil, 'juxta_change_index')).to eq('-')
    end

    it "returns - when juxta_change_index is nil" do
      @page_result.update!(juxta_change_index: nil)
      expect(helper.page_result_data(@page_result, 'juxta_change_index')).to eq('-')
    end
  end

  describe "#postproc_page_data" do
    before(:each) do
      @postproc_page = create(:postproc_page)
    end

    it "returns pp_ecorr" do
      expect(helper.postproc_page_data(@postproc_page, 'pp_ecorr')).to eq(@postproc_page.pp_ecorr)
    end

    it "returns - when postproc_page is nil" do
      expect(helper.postproc_page_data(nil, 'pp_ecorr')).to eq('-')
    end

    it "returns - when pp_ecorr is nil" do
      @postproc_page.update!(pp_ecorr: nil)
      expect(helper.postproc_page_data(@postproc_page, 'pp_ecorr')).to eq('-')
    end
  end
end
