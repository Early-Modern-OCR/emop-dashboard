require 'csv'

class DashboardController < ApplicationController
  # main dashboard summary view
  #
  def index
    @q = Work.ransack(params[:q])

    respond_to do |format|
      format.html { @queue_status = JobQueue.status_summary }
      format.json { render json: DashboardDatatable.new(view_context, @q) }
      format.csv do
        send_data @q.result.to_csv, filename: 'emop_dashboard_results.csv'
      end
    end
  end

  # Get an HTML fragment for the batch details tooltip
  #
  def batch
    @batch = BatchJob.find(params[:id])
    @job_type = @batch.job_type
    @ocr_engine = @batch.ocr_engine
    @font = @batch.font
    out = render_to_string(partial: 'batch_tooltip', layout: false)
    render text: out.strip
  end

  # Get errors for a work
  #
  def work_errors
    batch_job = BatchJob.find(params[:batch])
    work = Work.find(params[:work])
    job_queues = JobQueue.where(batch_job: batch_job, status: JobStatus.failed, work: work)

    resp = {}
    resp[:work] = params[:work]
    resp[:job] = batch_job.name
    errors = []
    job_queues.each do |job_queue|
      errors << { error: job_queue.results, page: job_queue.page.pg_ref_number }
    end
    resp[:errors] = errors

    render json: resp, status: :ok
  end

  # Reschedule failed batch
  #
  def reschedule
    # job info is passed down as a json string. String
    # is an array of objects. Each object has work and batch.
    # Decode the string and handle the request
    jobs = ActiveSupport::JSON.decode(params[:jobs])
    jobs.each do | job |
      work_id = job['work']
      batch_id = job['batch']
      # set job status back to scheduled
      job_queues = JobQueue.where(batch_id: batch_id, work_id: work_id)
      job_queues.reschedule!
    end
    render text: 'ok', status: :ok
  rescue => e
    logger.error("DashboardController#reschedule error: #{e.message}")
    render text: e.message, status: :error
  end

  # Create a new batch from json data in the POST payload
  #
  def create_batch
    # create the new batch
    job_type = JobType.find(params[:type_id])
    ocr_engine = OcrEngine.find(params[:engine_id])
    font = Font.find_by(font_id: params[:font_id])
    language_model = LanguageModel.find_by(id: params[:language_model_id])
    job_status_id = JobStatus.not_started.id
    batch_job_params = {
      name: params[:name],
      parameters: params[:params],
      notes: params[:notes],
      job_type: job_type,
      ocr_engine: ocr_engine,
      font: font,
      language_model: language_model,
      font_training_result_batch_job_id: params[:font_training_result_batch_job_id],
    }
    batch = BatchJob.create!(batch_job_params)
    batch_id = batch.id

    job_queue_columns = [
      :batch_id,
      :page_id,
      :job_status_id,
      :work_id
    ]

    # get the work id payload. If it is ALL, generate a
    # query to get all of the work IDs based on the current
    # filter settings
    json_payload = ActiveSupport::JSON.decode(params[:json])
    if json_payload['works'] == 'all'
      works = Work.ransack(ActiveSupport::JSON.decode(params[:q])).result

      jobs = []
      works.find_each do |work|
        work_id = work.id
        work.pages.find_each do |page|
          job = [batch_id, page.id, job_status_id, work_id]
          jobs << job
        end

        logger.debug "Write #{jobs.size} jobs..."
        JobQueue.import job_queue_columns, jobs, validate: false
        jobs = []
      end
    else
      # populate it with pages from the selected works
      jobs = []
      work_ids = json_payload['works']
      pages = Page.where(pg_work_id: work_ids)
      pages.find_each do | page |
        job = job = [batch_id, page.id, job_status_id, page.work.id]
        jobs << job
      end
      logger.debug "Write #{jobs.size} jobs..."
      JobQueue.import job_queue_columns, jobs, validate: false
    end

    # get a new summary for the job queue
    status = JobQueue.status_summary
    render json: ActiveSupport::JSON.encode(status), status: :ok
  rescue => e
    logger.error("DashboardController#create_batch error: #{e.message}")
    render text: e.message, status: :error
  end

  def test_exception_notifier
    raise 'This is a test of the exception notification system. This is not a real error.'
  end

end
