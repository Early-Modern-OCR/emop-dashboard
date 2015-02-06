module DashboardHelper
  def gt_filter_options(sel)
    options = [
      ['All', nil],
      ['With GT', 'with_gt'],
      ['Without GT', 'without_gt']
    ]
    options_for_select(options, sel)
  end

  def dataset_filter_options(sel)
    options = [
      ['All', nil],
      ['ECCO', 'ECCO'],
      ['EEBO', 'EEBO']
    ]
    options_for_select(options, sel)
  end

  def ocr_filter_options(sel)
    options = [
      ['All', nil],
      ['No OCR', 'ocr_none'],
      ['OCR Scheduled', 'ocr_sched'],
      ['OCR Complete', 'ocr_done'],
      ['OCR Ingested', 'ocr_ingest'],
      ['OCR Errors', 'ocr_error'],
      ['OCR Ingest Errors', 'ocr_ingest_error']
    ]
    options_for_select(options, sel)
  end

  def batch_filter_options(sel)
    options = options_from_collection_for_select(BatchJob.all, :id, :name, sel)
    options_for_select([['All', nil]]) + "\n" + options
  end

  def print_font_filter_options(sel)
    options = options_from_collection_for_select(PrintFont.all, :id, :name, sel)
    options_for_select([['All', nil]]) + "\n" + options
  end

  def work_checkbox(work)
    result = work.work_ocr_results.first
    if result.present? && result.batch_id.present?
      id = "#{work.id}-#{result.batch_id}"
    else
      id = "#{work.id}-0"
    end
    check_box_tag("sel-#{id}", nil, false, class: 'sel-cb')
  end

  def work_detail_link(work)
    result = work.work_ocr_results.first

    if result.present? && result.batch_id.present?
      url = results_path(work: work.id, batch: result.batch_id)
    else
      url = results_path(work: work.id)
    end

    link_to(url) do
      content_tag(:div, '', class: 'detail-link', title: 'View pages')
    end
  end

  def work_status(work)
    result = work.work_ocr_results.first
    if result.present? && result.batch_id.present?
      batch_id = result.batch_id
    else
      batch_id = nil
    end
    job_queues = JobQueue.where(batch_id: batch_id, work_id: work.id)

    not_started_cnt = job_queues.select { |j| j.status.name == 'Not Started' }.count
    processing_cnt = job_queues.select { |j| j.status.name == 'Processing' }.count
    done_cnt = job_queues.select { |j| j.status.name == 'Done' }.count
    failed_cnt = job_queues.select { |j| j.status.name == 'Failed' }.count

    html = []
    html << "<a class='status-text scheduled'>#{not_started_cnt}</a>"
    html << "<a class='status-text processing'>#{processing_cnt}</a>"
    html << "<a class='status-text success'>#{done_cnt}</a>"
    if failed_cnt > 0
      html << "<a id='status-#{batch_id}-#{work.id}' class='status-text error'>#{failed_cnt}</a>"
    else
      html << "<a class='status-text failed'>#{failed_cnt}</a>"
    end

    html.join('-')
  end

  def data_set(work)
    if work.wks_ecco_number.present?
      'ECCO'
    else
      'EEBO'
    end
  end

  def ocr_date(work)
    result = work.work_ocr_results.first
    if result.present? && result.ocr_completed.present?
      result.ocr_completed.to_datetime.strftime("%m/%d/%Y %H:%M")
    else
      ''
    end
  end

  def ocr_engine(work)
    result = work.work_ocr_results.first
    if result.present? && result.ocr_engine_id.present?
      OcrEngine.find(result.ocr_engine_id).name
    else
      ''
    end
  end

  def ocr_batch(work)
    result = work.work_ocr_results.first
    if result.present?
      content_tag(:span, class: 'batch-name', id: "batch-#{result.batch_id}") do
        "#{result.batch_id}: #{result.batch_name}"
      end
    else
      ''
    end
  end

  def accuracy_links(work, attribute)
    result = work.work_ocr_results.first
    return 'N/A' unless result.present?
    value = result.send(attribute)
    return 'N/A' unless value.present?

    if value < 0.6
      html_class = 'bad-cell'
    elsif value < 0.8
      html_class = 'warn-cell'
    else
      html_class = ''
    end
    formatted_value = '%.3f' % value

    link_to(results_path(work: work.id, batch: result.batch_id), class: html_class, title: 'View page results') do
      formatted_value
    end
  end
end
