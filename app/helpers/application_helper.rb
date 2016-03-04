module ApplicationHelper
  def git_version_info
    revision_file = File.join(Rails.root, 'REVISION')
    version_file = File.join(Rails.root, 'VERSION')

    if File.exists?(revision_file)
      revision = File.read(revision_file).chomp
    else
      revision = 'Unknown'
    end

    if File.exists?(version_file)
      version = File.read(version_file).chomp
    else
      version = 'Unknown'
    end

    "Version: #{version} Revision: #{revision}"
  end

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

  # REF: https://gist.github.com/roberto/3344628
  def bootstrap_class_for flash_type
    case flash_type
      when "success"
        "alert-success" # Green
      when "error"
        "alert-danger" # Red
      when "alert"
        "alert-warning" # Yellow
      when "notice"
        "alert-info" # Blue
      else
        flash_type.to_s
    end
  end
end
