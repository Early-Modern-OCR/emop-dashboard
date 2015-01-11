module ResultsHelper
  def page_image(page)
    "<a href=\"/results/#{page.pg_work_id}/page/#{page.pg_ref_number}\">" \
    "<div title='View page image' class='page-view'></div></a>"
  end

  def ocr_output_div_by_type(page_result, type)
    case type
    when 'text'
      title_segment = 'OCR text'
      attr_name = 'ocr_text_path'
      source_url = page_result_text_path(page_result) if page_result.present?
      div_class = 'ocr-txt'
    when 'hocr'
      title_segment = 'hOCR'
      attr_name = 'ocr_xml_path'
      source_url = page_result_hocr_path(page_result) if page_result.present?
      div_class = 'ocr-hocr'
    end

    options = {}
    options[:title] = "View #{title_segment} output"
    if page_result.present? and page_result.send(attr_name).present?
      options[:class] = div_class
      options[:data] = { source: source_url, id: page_result.id }
    else
      options[:class] = "#{div_class} disabled"
    end

    tag('div', options)
  end

  def detail_link(page_result)
    if page_result.present? && page_result.juxta_change_index.present?
      url = juxta_path(work: page_result.page.pg_work_id,
                       batch: page_result.batch_id,
                       page: page_result.page.pg_ref_number,
                       result: page_result.id)
      link_to(url, title: 'View side-by-side comparison with GT') do
        content_tag('div', '', class: 'juxta-link').html_safe
      end
    else
      content_tag('div', '', class: 'juxta-link disabled')
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
