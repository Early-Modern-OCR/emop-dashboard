module ApplicationHelper
  def page_status_icon(job_queue)
    if job_queue.present?
      status = job_queue.status.name
    else
      status = nil
    end

    case status
    when 'Not Started', 'Processing'
      html = "<div class='status-icon scheduled' title='OCR job scheduled'></div>"
    when 'Failed'
      html = "<div id='status-#{job_queue.batch_job.id}-#{job_queue.page.id}' class='status-icon error' title='OCR job failed'></div>"
    when 'Pending Postprocess', 'Postprocessing', 'Done'
      html = "<div class='status-icon success' title='Success'></div>"
    else
      html = "<div class='status-icon idle' title='Untested'></div>"
    end

    html
  end
end
