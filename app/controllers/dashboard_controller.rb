require 'csv'

class DashboardController < ApplicationController
  # main dashboard summary view
  #
  def index
    # pull extra filter data from session 
    @batch_filter = session[:batch]
    @set_filter = session[:set]
    @from_filter = session[:from]
    @to_filter = session[:to]
    @ocr_filter = session[:ocr]
    @gt_filter = session[:gt]
    @print_font_filter = session[:font]
   
    # get summary for queue
    @queue_status = JobQueue.status_summary
  end

  # Get an HTML fragment for the batch details tooltip
  #
  def batch      
    @batch = BatchJob.find( params[:id] )
    @job_type = @batch.job_type
    @ocr_engine = @batch.ocr_engine
    @font = @batch.font
    out = render_to_string( :partial => 'batch_tooltip', :layout => false )
    render :text => out.strip
  end

  # Called from dataTable to fetch a subset of data for display
  #
  def fetch
    # This shouldn't get called without parameters. If it does, then just return nothing, so there aren't exceptions later on.
    if params[:sSearch].nil?
      render :text => "", :status => :unprocessable_entity
      return
    end

    # NOTE: have sample data from TCP K072
    resp = {}
    resp['sEcho'] = params[:sEcho]
    resp['iTotalRecords'] = Work.count()

    # stuff filter params in session so they can be restored each view
    session[:search] = params[:sSearch]
    session[:gt] = params[:gt]
    session[:batch]  = params[:batch]
    session[:set] = params[:set]
    session[:from] = params[:from]
    session[:to] = params[:to]
    session[:ocr]  = params[:ocr]
    session[:font]  = params[:font]
  
    resp['data'], resp['iTotalDisplayRecords'] = do_query(params)
    render :json => resp, :status => :ok
  end

  def export
    # This shouldn't get called without parameters. If it does, then just return nothing, so there aren't exceptions later on.
    if params['q'].blank?
      render :text => "", :status => :unprocessable_entity
      return
    end
    # stuff filter params in session so they can be restored each view
    p = {}
    # duplicate the keys so that functions that look for either the symbol or the string will work.
    params['q'].each { |key,value|
      p[key.to_s] = value
      p[key.to_sym] = value
    }
    session[:search] = p[:sSearch]
    session[:gt] = p[:gt]
    session[:batch]  = p[:batch]
    session[:set] = p[:set]
    session[:from] = p[:from]
    session[:to] = p[:to]
    session[:ocr]  = p[:ocr]
    session[:font]  = p[:font]

    data, total = do_query(p)
    respond_to do |format|
      format.csv { send_data to_csv(data), :filename => "emop_dashboard_results.csv" }
    end
  end

  # Get errors for a work
  #
  def get_work_errors
    work_id = params[:work]
    batch_id = params[:batch]
    query = "select pg_ref_number, results from job_queues "
    query = query << " inner join pages on pg_page_id=page_id"
    query = query << " where job_status_id=? and batch_id=? and work_id=?"
    sql = [query, 6,batch_id,work_id]
    page_errors = JobQueue.find_by_sql( sql )
    out = {}
    out[:work] = work_id
    out[:job] = BatchJob.find(batch_id).name
    out_errors = []
    page_errors.each do | err |
      out_errors << {:page=>err.pg_ref_number, :error=>err.results}
    end
    out[:errors] = out_errors
    render  :json => out, :status => :ok
  end

  # Reschedule failed batch
  #
  def reschedule 
    begin
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
      render :text => "ok", :status => :ok
    rescue => e
      logger.error("DashboardController#reschedule error: #{e.message}")
      render :text => e.message, :status => :error
    end        
  end
   
  # Create a new batch from json data in the POST payload
  #
  def create_batch
    begin
      # create the new batch
      job_type = JobType.find(params[:type_id])
      ocr_engine = OcrEngine.find(params[:engine_id])
      font = Font.find(params[:font_id])
      batch_job_params = {
        name: params[:name],
        parameters: params[:params],
        notes: params[:notes],
        job_type: job_type,
        ocr_engine: ocr_engine,
        font: font,
      }
      batch = BatchJob.create!(batch_job_params)

      # get the work id payload. If it is ALL, generate a 
      # query to get all of the work IDs based on the current 
      # filter settings
      json_payload = ActiveSupport::JSON.decode(params[:json])
      if json_payload['works'] == 'all'
        works = Work.all
        if session[:gt].present?
          case session[:gt]
          when 'with_gt'
            works = works.with_gt
          when 'without_gt'
            works = works.without_gt
          end
        end
        if session[:batch].present?
          works = works.by_batch_job(session[:batch])
        end
        if session[:font].present?
          works = works.where(wks_primary_print_font: session[:font])
        end
        if session[:set].present?
          case session[:set]
          when 'EEBO'
            works = works.is_eebo
          when 'ECCO'
            works = works.is_ecco
          end
        end
        if session[:from].present?
          works = works.joins(:work_ocr_results).where("work_ocr_results.ocr_completed > ?", fix_date_format(session[:from]))
        end
        if session[:to].present?
          works = works.joins(:work_ocr_results).where("work_ocr_results.ocr_completed < ?", fix_date_format(session[:to]))
        end

        if session[:ocr].present?
          case session[:ocr]
          when 'ocr_done'
            works = works.ocr_done
          when 'ocr_sched'
            works = works.ocr_sched
          when 'ocr_ingest'
            works = works.ocr_ingest
          when 'ocr_ingest_error'
            works = works.ocr_ingest_error
          when 'ocr_none'
            works = works.ocr_none
          when 'ocr_error'
            works = works.ocr_error
          end
        end

        work_ids = []
        works.each do |work|
          work_ids << work.id
        end

        jobs = []
        jobs_batch_size = 5000
        pages = Page.where(pg_work_id: work_ids)
        pages.each do | page |
          job = JobQueue.new(batch_job: batch, page: page, status: JobStatus.not_started, work: page.work)
          jobs << job
          if jobs.size >= jobs_batch_size
            logger.debug "Write #{jobs.size} jobs..."
            JobQueue.import jobs
            jobs = []  
          end
        end 
        if jobs.size > 0
          logger.debug "Write #{jobs.size} jobs..."
          JobQueue.import jobs  
        end
      else 
        # populate it with pages from the selected works
        jobs = []
        work_ids = json_payload['works']
        pages = Page.where(pg_work_id: work_ids)
        pages.each do | page |
          job = JobQueue.new(batch_job: batch, page: page, status: JobStatus.not_started, work: page.work)
          jobs << job
        end
        logger.debug "Write #{jobs.size} jobs..."
        JobQueue.import jobs
      end   

      # get a new summary for the job queue
      status = JobQueue.status_summary
      render  :json => ActiveSupport::JSON.encode(status), :status => :ok  
         
    rescue => e
      logger.error("DashboardController#create_batch error: #{e.message}")
      render :text => e.message, :status => :error
    end 
  end

  def test_exception_notifier
    raise "This is a test of the exception notification system. This is not a real error."
  end

  private

  def fix_date_format ( src_date )
    bits = src_date.split("/")
    out = "#{bits[2]}-#{bits[0]}-#{bits[1]}"
    return out  
  end

  # Turn the activerecord data into a nice plan hash that jQuery dataTable can use
  #
  def result_to_hash(result)
    rec = {}
    rec[:id] = result.work_id

    # the checkbox id is a combination of work and batch id.
    # if there is no batch, it is workId-0
    id = "#{result.work_id}-0" if result.batch_id.nil?
    id = "#{result.work_id}-#{result.batch_id}" if !result.batch_id.nil?
    rec[:work_select] = "<input class='sel-cb' type='checkbox' id='sel-#{id}'>"

    if result.batch_id.nil?
      rec[:detail_link] = "<a href='results?work=#{result.work_id}'><div class='detail-link' title='View pages'></div></a>"
    else
      rec[:detail_link] = "<a href='results?work=#{result.work_id}&batch=#{result.batch_id}'><div class='detail-link' title='View pages'></div></a>"
    end

    rec[:status] = view_context.work_status(result.batch_id, result.work_id)

    if !result.ecco_number.nil? && result.ecco_number.length > 0
      rec[:data_set] = 'ECCO'
    else
      rec[:data_set] = 'EEBO'
    end

    rec[:tcp_number] = result.wks_tcp_number
    rec[:title] = result.title
    rec[:author] = result.author
    rec[:font] = result.font_name
    rec[:ocr_date] = nil
    rec[:ocr_engine] = nil
    rec[:ocr_batch] = nil
    rec[:juxta_url] = nil
    rec[:retas_url] = nil
    if !result.batch_id.nil? 
      rec[:ocr_date] = result.ocr_completed.to_datetime.strftime("%m/%d/%Y %H:%M") if result.has_attribute?(:ocr_completed)
      rec[:ocr_engine] = OcrEngine.find(result.ocr_engine_id ).name  if result.has_attribute?(:ocr_engine_id)
      rec[:ocr_batch] = "<span class='batch-name' id='batch-#{result.batch_id}'>#{result.batch_id}: #{result.batch_name}</span>"
      rec[:juxta_url] = gen_pages_link(result.work_id, result.batch_id, result.juxta_accuracy) if result.has_attribute?(:juxta_accuracy)
      rec[:retas_url] = gen_pages_link(result.work_id, result.batch_id, result.retas_accuracy) if result.has_attribute?(:retas_accuracy)
    end
    return rec
  end

=begin TODO: Remove once sure no longer needed
  def get_status(result)
    logger.debug("DEBUG: #{result.inspect}")
    if result.batch_id.nil?
      sql=["select count(*) as cnt from job_queues where page_id in (select pg_page_id from pages where pg_work_id=?)",result.work_id] 
      cnt = JobQueue.find_by_sql(sql).first.cnt
      if cnt == 0
        return "<div class='status-icon idle' title='Untested'></div>"
      else
        return "<div class='status-icon scheduled' title='OCR jobs are scheduled'></div>"
      end
    end

    sql = ["select job_status_id from job_queues where batch_id=? and page_id in (select pg_page_id from pages where pg_work_id=?)", 
            result.batch_id, result.work_id]
    jobs = JobQueue.find_by_sql(sql)
    status = "idle"
    msg = "Untested"
    id=nil
    jobs.each do |job|
      if job.job_status_id ==1 || job.job_status_id ==2
        if status != "error"
          status = "scheduled"
          msg = "OCR jobs are scheduled"   
        end
      end
      if job.job_status_id==6
        status = "error"
        msg = "OCR jobs have failed"
        id = "id='status-#{result.batch_id}-#{result.work_id}'"
        break
      end
      if job.job_status_id > 2 && job.job_status_id < 6
        if status != "error"
          status = "success"
          msg = "Success"
        end
      end
    end
    return "<div #{id} class='status-icon #{status}' title='#{msg}'></div>"
  end
=end

  def gen_pages_link(work_id, batch_id, accuracy)
    link_class = ""
    if accuracy.nil?
      out = "N/A"
    else
      if accuracy < 0.6
        link_class = "class='bad-cell'"
      elsif accuracy < 0.8
        link_class = "class='warn-cell'"
      end
      formatted = '%.3f'%accuracy
      out = "<a href='results?work=#{work_id}&batch=#{batch_id}' #{link_class} title='View page results'>#{formatted}</a>"
    end

    return out
  end

  # Create the monster select & where portion of the dashboard
  # results query. Use data in the session as filter.
  #
  def generate_query( )
    cond,vals = generate_conditions()

    # build the ugly query to get all the info
    work_fields = "wks_work_id as work_id, wks_tcp_number, wks_title as title, wks_author as author, wks_ecco_number as ecco_number"
    if session[:ocr] == 'ocr_sched'
      # special query to get SCHEDULED works; dont use work_ocr_results
      v_fields = ", pf_id, pf_name as font_name, batch_id, batch_jobs.name as batch_name, ocr_engine_id"
      sel = "select #{work_fields} #{v_fields} from works left outer join print_fonts on pf_id=wks_primary_print_font"
      sel << " left outer join job_queues on wks_work_id=job_queues.work_id "
      sel << " inner join batch_jobs on batch_jobs.id = batch_id "
    else
      v_fields = ", pf_id,pf_name as font_name, batch_id, ocr_completed, batch_name, ocr_engine_id, juxta_accuracy, retas_accuracy"
      sel = "select #{work_fields} #{v_fields} from works left outer join work_ocr_results on wks_work_id=work_id"
      sel << " left outer join print_fonts on pf_id=wks_primary_print_font "
    end

    where_clause = ""
    where_clause = "where #{cond}" if cond.length > 0
    return sel, where_clause, vals
  end
   
  def generate_conditions()
    q = session[:search]
    cond = ""
    vals = []
    if q.length > 0 
      cond = "(wks_work_id LIKE ? || wks_author LIKE ? || wks_title LIKE ?)"
      vals = ["%#{q}%", "%#{q}%", "%#{q}%" ]   
    end

    # add in extra filters:
    # NOTES: for ECCO, non-null TCP means GT is available
    #        for EEBO, non-null MARC means GT is avail
    if session[:gt].present?
      cond << " and" if cond.length > 0
      case session[:gt]
      when 'with_gt'
        cond << " (wks_tcp_number is not null or wks_marc_record is not null)"
      when 'without_gt'
        cond << " (wks_tcp_number IS NULL AND wks_marc_record IS NULL)"
      end
    end

    if !session[:batch].nil?
      cond << " and" if cond.length > 0
      cond << " batch_id=?"
      vals << session[:batch]
    end    

    if !session[:font].nil?
      cond << " and" if cond.length > 0
      cond << " pf_id=?"
      vals << session[:font]
    end    

    if !session[:set].nil?
      if session[:set] == 'EEBO'
        cond << " and" if cond.length > 0
        cond << " wks_ecco_number is null"
      elsif session[:set] == 'ECCO'
        cond << " and" if cond.length > 0
        cond << " wks_ecco_number is not null"
      end
    end

    if !session[:from].nil?
      cond << " and" if cond.length > 0
      cond << " work_ocr_results.ocr_completed > ?"
      vals << fix_date_format(session[:from])
    end
    if !session[:to].nil?
      cond << " and" if cond.length > 0
      cond << " work_ocr_results.ocr_completed < ?"
      vals << fix_date_format(session[:to])
    end

    if session[:ocr] == 'ocr_done'
      cond << " and" if cond.length > 0
      cond << " (select max(job_status_id) as js from job_queues where job_queues.batch_id=work_ocr_results.batch_id and job_queues.work_id=wks_work_id) in (3,4,5)"
      cond << " and (select min(job_status_id) as js from job_queues where  job_queues.batch_id=work_ocr_results.batch_id and job_queues.work_id=wks_work_id) > 2"
    elsif  session[:ocr] == 'ocr_sched'
      cond << " and" if cond.length > 0
      cond << " job_status_id < 3"
    elsif  session[:ocr] == 'ocr_ingest'
      cond << " and" if cond.length > 0
      cond << " (select max(job_status_id) as js from job_queues where job_queues.batch_id=work_ocr_results.batch_id and job_queues.work_id=wks_work_id)=5"
    elsif  session[:ocr] == 'ocr_ingest_error'
      cond << " and" if cond.length > 0
      cond << " (select max(job_status_id) as js from job_queues where job_queues.batch_id=work_ocr_results.batch_id and job_queues.work_id=wks_work_id)=7"
    elsif  session[:ocr] == 'ocr_none'
      cond << " and" if cond.length > 0
      cond << " work_ocr_results.ocr_completed is null"
    elsif session[:ocr] == 'ocr_error'
      cond << " and" if cond.length > 0
      cond << " (select max(job_status_id) as js from job_queues where job_queues.batch_id=work_ocr_results.batch_id and job_queues.work_id=wks_work_id)=6"
    end
    return cond, vals
  end

  def do_query(params)
    # enforce some rules on what columns can be sorted based on OCR filter setting:
    search_col_idx = params[:iSortCol_0].to_i
    if (search_col_idx == 9 || search_col_idx > 11) && params[:ocr] == "ocr_sched"
      # don't allow sort on results or date when error filter is on; no data exists for these
      search_col_idx = 4
    end
    if (search_col_idx > 8) && params[:ocr] == "ocr_none"
      # don't allow sort on any OCR data when NONE filter is on
      search_col_idx = 4
    end

    # generate order info based on params
    cols = [
      nil,nil,nil,nil,'wks_work_id',
      'wks_tcp_number','wks_title','wks_author',
      'font_name',
      'work_ocr_results.ocr_completed','ocr_engine_id',
      'batch_id','work_ocr_results.juxta_accuracy',
      'work_ocr_results.retas_accuracy'
    ]
    dir = params[:sSortDir_0]
    order_col = cols[search_col_idx]
    order_col = cols[4] if order_col.nil?

    # generate the select, conditional and vars parts of the query
    # the true parameter indicates that this result should include
    # all columns necessary to populate the dashboard view.
    sel, where_clause, vals = generate_query()

    # build the ugly query
    if params[:iDisplayStart].blank?
      limits = ""
    # TODO : Currently unused but allows for use of show 'All' 
    elsif params[:iDisplayLength] == '-1'
      limits = ""
    else
      limits = "limit #{params[:iDisplayLength]} OFFSET #{params[:iDisplayStart]}"
    end
    order = "order by #{order_col} #{dir}"
    if params[:ocr] == 'ocr_sched'
      # scheduled uses a different query that needs a group by to make the results work
      sql = ["#{sel} #{where_clause} group by work_id, batch_id #{order} #{limits}"]
    else
      sql = ["#{sel} #{where_clause} #{order} #{limits}"]
    end

    sql = sql + vals

    # get all of the results (paged)
    results = WorkOcrResult.find_by_sql(sql)

    # run a count query without the paging limits to get
    # the total number of results available
    pf_join = "left outer join print_fonts on pf_id=wks_primary_print_font"
    if params[:ocr] == 'ocr_sched'
      # search for scheduled uses different query to get data. Also need slightly
      # different query to get counts
      count_sel = "select count(distinct batch_id) as cnt from works #{pf_join} inner join job_queues on wks_work_id=job_queues.work_id "
    else
      count_sel = "select count(*) as cnt from works  #{pf_join} left outer join work_ocr_results on wks_work_id=work_id "
    end
    sql = ["#{count_sel} #{where_clause}"]
    sql = sql + vals
    filtered_cnt = Work.find_by_sql(sql).first.cnt

    # jam it all into an array of objects that match the dataTables structure
    data = []
    results.each do |result|
      rec = result_to_hash(result)
      data << rec
    end

    return data, filtered_cnt
  end

  def to_csv(data)
    column_names = [ 'Work ID', 'Data Set', 'Title', 'Author', 'Font', 'OCR Date', 'OCR Engine', 'OCR Batch', 'Juxta', 'RETAS' ]
    CSV.generate({}) do |csv|
      csv << column_names
      data.each do |row|
        line = []
        line.push(row[:id])
        line.push(row[:data_set])
        line.push(row[:title])
        line.push(row[:author])
        line.push(row[:font])
        line.push(row[:ocr_date])
        line.push(row[:ocr_engine])
        line.push(view_context.strip_tags(row[:ocr_batch]))
        line.push(view_context.strip_tags(row[:juxta_url]))
        line.push(view_context.strip_tags(row[:retas_url]))
        csv << line
      end
    end
  end

end
