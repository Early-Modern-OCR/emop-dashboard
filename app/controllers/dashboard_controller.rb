class DashboardController < ApplicationController
   # main dashboard summary view
   #
   def index
      # TODO get data for summary table
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

      # build the ugly query to get all the info
      sel = "select works.*,work_ocr_results.* from work_ocr_results right outer join works on wks_work_id=work_id"
      limits = "limit #{params[:iDisplayLength]} OFFSET #{params[:iDisplayStart]}"
      order = "order by #{order_col} #{dir}"
      sql = ["#{sel} where #{cond} #{order} #{limits}"]
      sql = sql + vals

      results = WorkOcrResult.find_by_sql(sql)
      filter_cond = [cond]+vals
      filtered_cnt = results.size#WorkOcrResult.count(:conditions => filter_cond)
      
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
   def result_to_hash(result)
     rec = {}
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
         rec[:ocr_batch] = "#{result.batch_id}: #{result.batch_name}"
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
      out = "<a href='page/#{work_id}?batch=#{batch_id}' #{link_class}>#{formatted}</a>"
      return out   
   end

end
