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

  describe "#ocr_text" do
    before(:each) do
      @page_result = create(:page_result)
    end

    it "returns view OCR text HTML" do
      expect(helper.ocr_text(@page_result)).to \
        have_tag('div', with: { id: "result-#{@page_result.id}", class: 'ocr-txt', title: 'View OCR text output'})
    end

    it "returns disabled HTML" do
      expect(helper.ocr_text(nil)).to have_tag('div', with: { class: 'ocr-txt disabled', title: 'View OCR text output'})
    end
  end

  describe "#ocr_hocr" do
    before(:each) do
      @page_result = create(:page_result)
    end

    it "returns view OCR text HTML" do
      expect(helper.ocr_hocr(@page_result)).to \
        have_tag('div', with: { id: "hocr-#{@page_result.id}", class: 'ocr-hocr', title: 'View hOCR output'})
    end

    it "returns disabled HTML" do
      expect(helper.ocr_hocr(nil)).to have_tag('div', with: { class: 'ocr-hocr disabled', title: 'View hOCR output'})
    end
  end

  describe "#detail_link" do
    before(:each) do
      @page_result = create(:page_result)
    end

    it "returns GT comparison link" do
      expected_href = "/juxta?work=#{@page_result.page.pg_work_id}" \
                      "&batch=#{@page_result.batch_id}&page=#{@page_result.page.pg_ref_number}" \
                      "&result=#{@page_result.id}"
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
