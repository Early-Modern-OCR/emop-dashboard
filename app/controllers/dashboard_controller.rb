class DashboardController < ApplicationController
   # main dashboard summary view
   #
   def index
      # pull extra filter data from session 
      @batch_filter = session[:batch]
      @from_filter = session[:from]
      @to_filter = session[:to]
      @ocr_filter = session[:ocr]

      @batches = BatchJob.all()
   end
   
   # Get an HTML fragment for the batch details tooltip
   def batch      
      @batch = BatchJob.find( params[:id] )
      @job_type = JobType.find( @batch.job_type )
      @ocr_engine = OcrEngine.find( @batch.ocr_engine_id )
      @font = @batch.font
      out = render_to_string( :partial => 'batch_tooltip', :layout => false )
      render :text => out.strip
   end

   # Called from datatable to fetch a subset of data for display
   #
   def fetch
      # NOTE: have sample data from TCP K072
      puts params
      resp = {}
      resp['sEcho'] = params[:sEcho]
      resp['iTotalRecords'] = Work.count(:wks_tcp_number)
      
      # generate order info based on params
      search_col_idx = params[:iSortCol_0].to_i
      cols = [nil,'wks_tcp_number','wks_title','wks_author',
              'work_ocr_results.ocr_completed','work_ocr_results.ocr_engine_id',
              'work_ocr_results.batch_id','work_ocr_results.juxta_accuracy',
              'work_ocr_results.retas_accuracy']
      dir = params[:sSortDir_0]
      order_col = cols[search_col_idx]
      order_col = cols[1] if order_col.nil?
      
  
      # build where conditions
      q = params[:sSearch]
      cond = "wks_tcp_number is not null"
      vals = []
      if q.length > 0 
         cond = "wks_tcp_number is not null && (wks_tcp_number LIKE ? || wks_author LIKE ? || wks_title LIKE ?)"
         vals = ["%#{q}%", "%#{q}%", "%#{q}%" ]   
      end
      
      # add in extra filters; batch, from date and to date
      batch_filter = params[:batch]
      session[:batch]  = batch_filter
      if !batch_filter.nil?
         cond << " and work_ocr_results.batch_id=?"
         vals << batch_filter
      end
      from_filter = params[:from]
      session[:from]  = from_filter
      if !from_filter.nil?
         cond << " and work_ocr_results.ocr_completed > ?"
         vals << fix_date_format(from_filter)
      end
      to_filter = params[:to]
      session[:to]  = to_filter
      if !to_filter.nil?
         cond << " and work_ocr_results.ocr_completed < ?"
         vals << fix_date_format(to_filter)
      end
      
      session[:ocr]  = params[:ocr]
      if params.has_key?(:ocr)
         cond << " and work_ocr_results.ocr_completed is not null"
      end

      # build the ugly query to get all the info
      sel = "select works.*,work_ocr_results.* from work_ocr_results right outer join works on wks_work_id=work_id"
      limits = "limit #{params[:iDisplayLength]} OFFSET #{params[:iDisplayStart]}"
      order = "order by #{order_col} #{dir}"
      sql = ["#{sel} where #{cond} #{order} #{limits}"]
      sql = sql + vals

      results = WorkOcrResult.find_by_sql(sql)
      
      count_sel = "select count(*) as cnt from work_ocr_results right outer join works on wks_work_id=work_id"
      sql = ["#{count_sel} where #{cond}"]
      sql = sql + vals
      filtered_cnt = WorkOcrResult.find_by_sql(sql).first.cnt
      
      data = []
      results.each do |result|
         rec = result_to_hash(result)   
         data << rec 
      end
            
      resp['data'] = data
      resp['iTotalDisplayRecords'] = filtered_cnt
      render :json => resp, :status => :ok
   end
  
   private
   def fix_date_format ( src_date )
      bits = src_date.split("/")
      out = "#{bits[2]}-#{bits[0]}-#{bits[1]}"
      return out  
   end
   
   private
   def result_to_hash(result)
     rec = {}
      rec[:detail_link] = "<a href='results?work=#{result.wks_work_id}'><div class='detail-link'></div></a>"

      if result.wks_ecco_number.nil? && result.wks_ecco_number.length > 0
         rec[:data_set] = 'ECCO'
      else
         rec[:data_set] = 'EEBO'   
      end 
      rec[:tcp_number] = result.wks_tcp_number
      rec[:title] = result.wks_title
      rec[:author] = result.wks_author
      if result.batch_id.nil?
         rec[:ocr_date] = nil
         rec[:ocr_engine] = nil
         rec[:ocr_batch] = nil
         rec[:juxta_url] = nil
         rec[:retas_url] = nil
      else
         rec[:ocr_date] = result.ocr_completed.to_datetime.strftime("%m/%d/%Y %H:%M")
         rec[:ocr_engine] = OcrEngine.find(result.ocr_engine_id ).name
         rec[:ocr_batch] = "<span class='batch-name' id='batch-#{result.batch_id}'>#{result.batch_id}: #{result.batch_name}</span>"
         rec[:juxta_url] = gen_pages_link(result.wks_work_id, result.batch_id, result.juxta_accuracy)
         rec[:retas_url] = gen_pages_link(result.wks_work_id, result.batch_id, result.retas_accuracy)
      end
      return rec
   end
   
   private
   def gen_pages_link(work_id, batch_id, accuracy)
      link_class = ""
      if accuracy < 0.6
         link_class = "class='bad-cell'"
      elsif accuracy < 0.8
         link_class = "class='warn-cell'"
      end
      formatted = '%.3f'%accuracy
      out = "<a href='results?work=#{work_id}&batch=#{batch_id}' #{link_class}>#{formatted}</a>"
      return out   
   end

end
