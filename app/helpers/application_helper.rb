module ApplicationHelper
  def page_status_icon(job_queue)
    if job_queue.present?
      status = job_queue.status.name
    else
      status = nil
    end

    case status
    when 'Not Started'
      html = "<div class='status-icon scheduled' title='OCR job scheduled'></div>"
    when 'Processing'
      html = "<div class='status-icon processing' title='OCR job processing'></div>"
    when 'Failed'
      html = "<div id='status-#{job_queue.batch_job.id}-#{job_queue.page.id}' class='status-icon error' title='OCR job failed'></div>"
    when 'Pending Postprocess', 'Postprocessing', 'Done'
      html = "<div class='status-icon success' title='Success'></div>"
    else
      html = "<div class='status-icon idle' title='Untested'></div>"
    end

    html
  end

  def work_status(batch_id, work_id)
    job_queues = JobQueue.where(batch_id: batch_id, work_id: work_id)

    not_started_cnt = job_queues.select { |j| j.status.name == 'Not Started' }.count
    processing_cnt = job_queues.select { |j| j.status.name == 'Processing' }.count
    done_cnt = job_queues.select { |j| j.status.name == 'Done' }.count
    failed_cnt = job_queues.select { |j| j.status.name == 'Failed' }.count

    html = []
    html << "<a class='status-text scheduled'>#{not_started_cnt}</a>"
    html << "<a class='status-text processing'>#{processing_cnt}</a>"
    html << "<a class='status-text success'>#{done_cnt}</a>"
    if failed_cnt > 0
      html << "<a id='status-#{batch_id}-#{work_id}' class='status-text error'>#{failed_cnt}</a>"
    else
      html << "<a class='status-text failed'>#{failed_cnt}</a>"
    end

    html.join('-')
  end
end
