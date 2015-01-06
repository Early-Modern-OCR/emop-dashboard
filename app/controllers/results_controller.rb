require 'RMagick'

class ResultsController < ApplicationController
  # show the page details for the specified work
  #
  def show
    @work_id = params[:work]
    @batch_id = params[:batch]
    work = Work.find(@work_id)
    @work_title = work.wks_title

    if !@batch_id.nil?
      batch = BatchJob.find(@batch_id)
      @batch = "#{batch.id}: #{batch.name}"
    else
      @batch = 'Not Applicable'
    end

    if work.print_font.present?
      @print_font = work.print_font.name
    else
      @print_font = 'Not Set'
    end
  end

  # Fetch data for dataTable
  #
  def fetch
    # This shouldn't get called without parameters.
    # If it does, then just return nothing, so there aren't exceptions later on.
    if params[:work].nil?
      render text: '', status: :unprocessable_entity
      return
    end

    work_id = params[:work]
    batch_id = params[:batch]

    resp = {}
    resp['sEcho'] = params[:sEcho]

    if batch_id.present?
      # generate order info based on params
      search_col_idx = params[:iSortCol_0].to_i
      cols = [
        nil, 'job_queues.job_status_id', nil, nil, nil, nil,
        'pg_ref_number', 'page_results.juxta_change_index', 'page_results.alt_change_index',
        'postproc_pages.pp_ecorr', 'postproc_pages.pp_pg_quality'
      ]
      dir = params[:sSortDir_0]
      dir = 'asc' if dir.nil?
      order_col = cols[search_col_idx]
      order_col = cols[6] if order_col.nil?

      pages = Page.includes(:job_queues, :page_results, :postproc_pages)
              .order("#{order_col} #{dir}")
              .where(pg_work_id: work_id, job_queues: { batch_id: batch_id })
    else
      dir = params[:sSortDir_0]
      dir = :asc if dir.nil?
      pages = Page.order(pg_ref_number: dir).where(pg_work_id: work_id)
    end

    resp['iTotalRecords'] = pages.count
    resp['iTotalDisplayRecords'] = resp['iTotalRecords']

    # get results and transform them into req'd json structure
    data = []
    msg = 'View side-by-side comparison with GT'
    pages.each do | page |
      # The use of "select" avoids extra queries on already collected results
      page_result = page.page_results.select { |pr| pr.batch_id == batch_id.to_i }.first
      postproc_page = page.postproc_pages.select { |pp| pp.batch_job_id == batch_id.to_i }.first
      job_queue = page.job_queues.first
      rec = {}
      rec[:page_select] = "<input class='sel-cb' type='checkbox' id='sel-page-#{page.id}'>"
      rec[:status] = view_context.page_status_icon(job_queue)
      rec[:page_image] = "<a href=\"/results/#{work_id}/page/#{page.pg_ref_number}\">" \
                         "<div title='View page image' class='page-view'></div></a>"
      rec[:page_number] = page.pg_ref_number
      # These are defaults that can be overriden if needed values exist
      rec[:ocr_text] = "<div class='ocr-txt disabled' title='View OCR text output'>"
      rec[:ocr_hocr] = "<div class='ocr-hocr disabled' title='View hOCR output'>"
      rec[:detail_link] = "<div class='juxta-link disabled'>"
      rec[:juxta_accuracy] = '-'
      rec[:retas_accuracy] = '-'
      rec[:pp_ecorr] = '-'
      rec[:pp_pg_quality] = '-'
      # Items from page_results
      if page_result.present?
        rec[:ocr_text] = "<div id='result-#{page_result.id}' class='ocr-txt' title='View OCR text output'>"
        rec[:ocr_hocr] = "<div id='hocr-#{page_result.id}' class='ocr-hocr' title='View hOCR output'>"
        if page_result.juxta_change_index.present?
          rec[:juxta_accuracy] = page_result.juxta_change_index
          rec[:detail_link] = "<a href='/juxta?work=#{work_id}&batch=#{batch_id}&page=#{page.pg_ref_number}" \
                              "&result=#{page_result.id}' title='#{msg}'><div class='juxta-link'></div></a>"
        end
        if page_result.alt_change_index.present?
          rec[:retas_accuracy] = page_result.alt_change_index
        end
      end
      # Items from postproc_pages
      if postproc_page.present?
        if postproc_page.pp_ecorr.present?
          rec[:pp_ecorr] = postproc_page.pp_ecorr
        end
        if postproc_page.pp_pg_quality.present?
          rec[:pp_pg_quality] = postproc_page.pp_pg_quality
        end
      end
      data << rec
    end

    resp['data'] = data
    render json: resp, status: :ok
  end

  # Get the OCR text result for the specified page_result
  #
  def page_text
    page_result = PageResult.find(params[:id])
    if File.exist?(page_result.local_idhmc_text_path)
      file = File.open(page_result.local_idhmc_text_path, 'r')
      text_path = page_result.local_idhmc_text_path
    elsif File.exist?(page_result.local_text_path)
      file = File.open(page_result.local_text_path, 'r')
      text_path = page_result.local_text_path
    end

    if file.present?
      contents = file.read
      file.close
    else
      contents = 'File not found!'
    end

    if text_path.present? && params.key?(:download)
      token = params[:token]
      filename = File.basename(text_path)
      send_data(contents, filename: filename,  type: 'text/plain', disposition: 'attachment')
      cookies[:fileDownloadToken] = { value: "#{token}", expires: Time.now + 5 }
    else
      resp = {}
      resp[:page] = page_result.page.pg_ref_number
      resp[:content] = contents
      render json: resp, status: :ok
    end
  end

  # Get the hOCR for the specified page_result
  #
  def page_hocr
    page_result = PageResult.find(params[:id])
    if File.exist?(page_result.local_idhmc_xml_path)
      file = File.open(page_result.local_idhmc_xml_path)
      xml_path = page_result.local_idhmc_xml_path
    elsif File.exist?(page_result.local_xml_path)
      file = File.open(page_result.local_xml_path)
      xml_path = page_result.local_xml_path
    end

    if file.present?
      contents = file.read
      file.close
    else
      contents = 'File not found!'
    end

    if xml_path.present? && params.key?(:download)
      token = params[:token]
      filename = File.basename(xml_path)
      send_data(contents, filename: filename,  type: 'text/xml', disposition: 'attachment')
      cookies[:fileDownloadToken] = { value: "#{token}", expires: Time.now + 5 }
    else
      resp = {}
      resp[:page] = page_result.page.pg_ref_number
      resp[:content] = contents
      render json: resp, status: :ok
    end
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
      PageResult.where(batch_id: batch_id, page_id: page_id).destroy_all
      PostprocPage.where(batch_job_id: batch_id, page_id: page_id).destroy_all
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
    @font = Font.find(params[:font_id])
    @batch_job = BatchJob.new(name: params[:name], parameters: params[:params], notes: params[:notes])
    @batch_job.job_type = @job_type
    @batch_job.ocr_engine = @ocr_engine
    @batch_job.font = @font
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
      ebbo_dir = work.wks_eebo_directory
      (0..100).each do |version_num|
        img_file = format('%s%s/%05d.000.%03d.tif', emop_path_prefix, ebbo_dir, page_num, version_num)
        return img_file if File.exist?(img_file)
      end
      return '' # NOT FOUND!
    end
  end
end
