module ApplicationHelper
  def page_status_icon(job_queue)
    if job_queue.present?
      status = job_queue.status.name
      id = job_queue.status.id
    else
      status = nil
      id = 0
    end

    case status
    when 'Not Started'
      html = "<div class='status-icon scheduled' title='OCR job scheduled' data-id='#{id}'></div>"
    when 'Processing'
      html = "<div class='status-icon processing' title='OCR job processing' data-id='#{id}'></div>"
    when 'Failed'
      html = "<div id='status-#{job_queue.batch_job.id}-#{job_queue.page.id}' " \
             "class='status-icon error' title='OCR job failed' data-id='#{id}'></div>"
    when 'Pending Postprocess', 'Postprocessing', 'Done'
      html = "<div class='status-icon success' title='Success' data-id='#{id}'></div>"
    else
      html = "<div class='status-icon idle' title='Untested' data-id='#{id}'></div>"
    end

    html
  end
end
