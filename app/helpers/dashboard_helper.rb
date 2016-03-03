module DashboardHelper
  def gt_filter_options(sel)
    options = [
      ['All', nil],
      ['With GT', 'with_gt'],
      ['Without GT', 'without_gt']
    ]
    options_for_select(options, sel)
  end

  def collection_filter_options(sel)
    options = options_from_collection_for_select(WorksCollection.all, :id, :name, sel)
    options_for_select([['All', nil]]) + "\n" + options
  end

  def language_filter_options(sel)
    options = options_from_collection_for_select(Language.all, :id, :name, sel)
    options_for_select([['All', nil]]) + "\n" + options
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

  def link_to_add_fields(name, f, type)
    new_object = f.object.send "build_#{type}"
    id = "new_#{type}"
    fields = f.send("#{type}_fields", new_object, child_index: id) do |builder|
      render(type.to_s + "_fields", f: builder)
    end
    link_to(name, '#', class: "add_fields", data: {id: id, fields: fields.gsub("\n", "")})
  end

  def work_checkbox(work, batch_job)
    if batch_job.present?
      id = "#{work.id}-#{batch_job.id}"
    else
      id = "#{work.id}-0"
    end
    check_box_tag("sel-#{id}", nil, false, class: 'sel-cb')
  end

  def work_detail_link(work, batch_job)
    if batch_job.present?
      url = results_path(work: work.id, batch: batch_job.id)
    else
      url = results_path(work: work.id)
    end

    link_to(url) do
      content_tag(:div, '', class: 'detail-link', title: 'View pages')
    end
  end

  def work_status(work, batch_job)
    if batch_job.present?
      not_started_id = JobStatus.not_started.id
      processing_id = JobStatus.processing.id
      done_id = JobStatus.done.id
      failed_id = JobStatus.failed.id
      job_queues = JobQueue.select(:id, :job_status_id).where(batch_id: batch_job.id, work_id: work.id)
      not_started_cnt = job_queues.select { |j| j.job_status_id == not_started_id }.count
      processing_cnt = job_queues.select { |j| j.job_status_id == processing_id }.count
      done_cnt = job_queues.select { |j| j.job_status_id == done_id }.count
      failed_cnt = job_queues.select { |j| j.job_status_id == failed_id }.count
    else
      not_started_cnt = 0
      processing_cnt = 0
      done_cnt = 0
      failed_cnt = 0
    end

    html = []
    html << "<a class='status-text scheduled'>#{not_started_cnt}</a>"
    html << "<a class='status-text processing'>#{processing_cnt}</a>"
    html << "<a class='status-text success'>#{done_cnt}</a>"
    if failed_cnt > 0
      html << "<a id='status-#{batch_job.id}-#{work.id}' class='status-text error'>#{failed_cnt}</a>"
    else
      html << "<a class='status-text failed'>#{failed_cnt}</a>"
    end

    html.join('-')
  end

  def ocr_date(work)
    if work.ocr_result.present? && work.ocr_result.ocr_completed.present?
      work.ocr_result.ocr_completed.to_datetime.strftime("%m/%d/%Y %H:%M")
    else
      ''
    end
  end

  def ocr_engine(work, batch_job)
    if batch_job.present?
      batch_job.ocr_engine.name
    else
      ''
    end
  end

  def ocr_batch(work, batch_job)
    if batch_job.present?
      content_tag(:span, class: 'batch-name', id: "batch-#{batch_job.id}") do
        "#{batch_job.id}: #{batch_job.name}"
      end
    else
      ''
    end
  end

  def accuracy_links(work, attribute)
    value = work.send(attribute)
    return 'N/A' unless value.present?

    if value < 0.6
      html_class = 'bad-cell'
    elsif value < 0.8
      html_class = 'warn-cell'
    else
      html_class = ''
    end
    formatted_value = '%.3f' % value

    link_to(results_path(work: work.id, batch: work.ocr_result_batch_job.id), class: html_class, title: 'View page results') do
      formatted_value
    end
  end
end
