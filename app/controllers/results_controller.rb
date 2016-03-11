require 'RMagick'

class ResultsController < ApplicationController
  # show the page details for the specified work
  #
  def show
    @work = Work.find(params[:work])

    if params[:batch].present?
      @batch_job = BatchJob.find(params[:batch])
      @pages = Page.includes(:job_queues, :page_results, :postproc_pages)
              .where(pg_work_id: @work.id, job_queues: { batch_id: @batch_job.id })
    else
      @pages = Page.where(pg_work_id: @work.id)
    end

    @stats = [
      'total',
      'ignored',
      'correct',
      'corrected',
      'unchanged',
    ]
  end

  # Get the OCR text result for the specified page_result
  #
  def page_text
    page_result = PageResult.find(params[:id])
    local_text_path = page_result.local_text_path
    local_idhmc_text_path = page_result.local_idhmc_text_path
    local_corr_text_path = page_result.local_corr_text_path
    response = {}
    response[:page] = page_result.page.pg_ref_number
    response[:original_content] = get_file_content(local_text_path)
    response[:original_path] = local_text_path
    response[:original_url] = download_page_result_path(id: page_result.id, type: 'original_text')
    response[:processed_content] = get_file_content(local_idhmc_text_path)
    response[:processed_path] = local_idhmc_text_path
    response[:processed_url] = download_page_result_path(id: page_result.id, type: 'processed_text')
    response[:corrected_content] = get_file_content(local_corr_text_path)
    response[:corrected_path] = local_corr_text_path
    response[:corrected_url] = download_page_result_path(id: page_result.id, type: 'corrected_text')

    render json: response, status: :ok
  end

  # Get the hOCR for the specified page_result
  #
  def page_hocr
    page_result = PageResult.find(params[:id])
    local_xml_path = page_result.local_xml_path
    local_idhmc_xml_path = page_result.local_idhmc_xml_path
    local_corr_xml_path = page_result.local_corr_xml_path
    response = {}
    response[:page] = page_result.page.pg_ref_number
    response[:original_content] = get_file_content(local_xml_path)
    response[:original_path] = local_xml_path
    response[:original_url] = download_page_result_path(id: page_result.id, type: 'original_xml')
    response[:processed_content] = get_file_content(local_idhmc_xml_path)
    response[:processed_path] = local_idhmc_xml_path
    response[:processed_url] = download_page_result_path(id: page_result.id, type: 'processed_xml')
    response[:corrected_content] = get_file_content(local_corr_xml_path)
    response[:corrected_path] = local_corr_xml_path
    response[:corrected_url] = download_page_result_path(id: page_result.id, type: 'corrected_xml')

    render json: response, status: :ok
  end

  def download_result
    page_result = PageResult.find(params[:id])
    type = params[:type]
    token = params[:token]

    case type
    when 'original_text'
      path = page_result.local_text_path
      type = 'text/plain'
    when 'processed_text'
      path = page_result.local_idhmc_text_path
      type = 'text/plain'
    when 'corrected_text'
      path = page_result.local_corr_text_path
      type = 'text/plain'
    when 'original_xml'
      path = page_result.local_xml_path
      type = 'text/xml'
    when 'processed_xml'
      path = page_result.local_idhmc_xml_path
      type = 'text/xml'
    when 'corrected_xml'
      path = page_result.local_corr_xml_path
      type = 'text/xml'
    end

    unless File.exist?(path)
      flash[:alert] = 'Page result file not found!'
      redirect_to_referrer && return
    end

    contents = get_file_content(path)
    filename = File.basename(path)

    send_data(contents, filename: filename,  type: type, disposition: 'attachment')
    cookies[:fileDownloadToken] = { value: "#{token}", expires: Time.now + 5 }
  end

  # Get the error for a page
  #
  def page_error
    job_queue = JobQueue.where(page_id: params[:page], batch_id: params[:batch]).first
    out = {}
    out[:page] = job_queue.page.pg_ref_number
    out[:error] = job_queue.results
    render json: out, status: :ok
  end

  # Reschedule failed page
  #
  def reschedule
    page_ids = params[:pages]
    batch_id = params[:batch]
    page_ids.each do |page_id|
      job_queues = JobQueue.where(batch_id: batch_id, page_id: page_id)
      job_queues.reschedule!
      job_queues.update_all(last_update: Time.now)
    end
    render text: 'ok', status: :ok
  rescue => e
    render text: e.message, status: :error
  end

  # Create a new batch from json data in the POST payload
  #
  def create_batch
    # create the new batch
    @job_type = JobType.find(params[:type_id])
    @ocr_engine = OcrEngine.find(params[:engine_id])
    @font = Font.find_by(font_id: params[:font_id])
    @language_model = LanguageModel.find_by(id: params[:language_model_id])
    @batch_job = BatchJob.new(name: params[:name], parameters: params[:params], notes: params[:notes])
    @batch_job.job_type = @job_type
    @batch_job.ocr_engine = @ocr_engine
    @batch_job.font = @font
    @batch_job.language_model = @language_model
    @batch_job.font_training_result_batch_job_id = params[:font_training_result_batch_job_id]
    @batch_job.save!

    # populate it with pages from the selected works
    # payload: {work: id, pages: [pageId,pageId...]}
    json_payload = ActiveSupport::JSON.decode(params[:json])
    job_queues = []
    pages = Page.where(pg_page_id: json_payload['pages'], pg_work_id: json_payload['work'])
    pages.each do |page|
      @job_queue = JobQueue.new(batch_job: @batch_job, page: page, work: page.work)
      job_queues << @job_queue
    end
    JobQueue.import(job_queues)

    render text: @batch_job.id, status: :ok
  rescue => e
    render text: e.message, status: :error
  end

  def add_to_batchjob
    if request.get?
      respond_to do |format|
        format.js
      end
    else
      if not params[:batch_job].present?
        return redirect_to :back, flash: { error: "Must select a Batch Job" }
      end
      if not params[:page_ids].present?
        return redirect_to :back, flash: { error: "Must select pages" }
      end
      job_queues = []
      page_ids = JSON.parse(params[:page_ids])
      @batch_job = BatchJob.find(params[:batch_job])
      page_ids.each do |page_id|
        @page = Page.find(page_id)
        @job_queue = JobQueue.new(batch_job: @batch_job, page: @page, work: @page.work)
        job_queues << @job_queue
      end

      JobQueue.import(job_queues)

      redirect_to :back, flash: { success: "Added pages to Batch Job #{@batch_job.id}-#{@batch_job.name}" }
    end
  end

  # Get TIFF page image, convert it to PNG and stream it back to client
  #
  def page_image
    page_num = params[:num]
    @work = Work.find(params[:work])
    img_path = get_ocr_image_path(@work, page_num)
    unless File.exist?(img_path)
      flash[:alert] = 'Image file not found!'
      redirect_to_referrer && return
    end
    img = Magick::Image.read(img_path).first
    img.format = 'PNG'
    send_data img.to_blob, type: 'image/png', disposition: 'inline', x_sendfile: true
  end

  private

  # TODO: This needs to either be handled by the Page model
  #       or the database needs to have complete records.
  def get_ocr_image_path(work, page_num)
    emop_path_prefix = Rails.application.secrets.emop_path_prefix
    # first, see if the image path was stored in DB. If so, use it
    page = Page.where(pg_work_id: work.id, pg_ref_number: page_num).first
    if !page.nil? && !page.pg_image_path.blank?
      return "#{emop_path_prefix}#{page.pg_image_path}"
    end

    # not in db; try to generate it
    if work.isECCO?
      # ECCO format: ECCO number + 4 digit page + 0.tif
      ecco_dir = work.wks_ecco_directory
      return format('%s%s/%s%04d0.TIF', emop_path_prefix, ecco_dir, work.wks_ecco_number, page_num)
    else
      # EEBO format: 00014.000.001.tif where 00014 is the page number.
      # EEBO is a problem because of the last segment before .tif. It is some
      # kind of version info and can vary. Start with 0 and increase til
      # a file is found.
      ebbo_dir = work.wks_doc_directory
      (0..100).each do |version_num|
        img_file = format('%s%s/%05d.000.%03d.tif', emop_path_prefix, ebbo_dir, page_num, version_num)
        return img_file if File.exist?(img_file)
      end
      return '' # NOT FOUND!
    end
  end

  def get_file_content(path)
    if path && File.exist?(path)
      file = File.open(path, 'r')
      contents = file.read
      file.close
    else
      contents = 'File not found!'
    end
    contents
  end
end
