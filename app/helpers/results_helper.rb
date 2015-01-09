module ResultsHelper
  def page_image(page)
    "<a href=\"/results/#{page.pg_work_id}/page/#{page.pg_ref_number}\">" \
    "<div title='View page image' class='page-view'></div></a>"
  end

  def ocr_text(page_result)
    if page_result.present?
      "<div id='result-#{page_result.id}' class='ocr-txt' title='View OCR text output'>"
    else
      "<div class='ocr-txt disabled' title='View OCR text output'>"
    end
  end

  def ocr_hocr(page_result)
    if page_result.present?
      "<div id='hocr-#{page_result.id}' class='ocr-hocr' title='View hOCR output'>"
    else
      "<div class='ocr-hocr disabled' title='View hOCR output'>"
    end
  end

  def detail_link(page_result)
    if page_result.present? && page_result.juxta_change_index.present?
      "<a href='/juxta?work=#{page_result.page.pg_work_id}&batch=#{page_result.batch_id}" \
      "&page=#{page_result.page.pg_ref_number}&result=#{page_result.id}' " \
      "title='View side-by-side comparison with GT'><div class='juxta-link'></div></a>"
    else
      "<div class='juxta-link disabled'>"
    end
  end

  def page_result_data(page_result, data)
    if page_result.present? && page_result.send(data).present?
      page_result.send(data)
    else
      '-'
    end
  end

  def postproc_page_data(postproc_page, data)
    if postproc_page.present? && postproc_page.send(data).present?
      postproc_page.send(data)
    else
      '-'
    end
  end
end
