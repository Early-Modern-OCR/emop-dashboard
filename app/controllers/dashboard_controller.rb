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
      sel = "select works.*,work_ocr_results.* from works left outer join work_ocr_results on wks_work_id=work_id"
      limits = "limit #{params[:iDisplayLength]} OFFSET #{params[:iDisplayStart]}"
      order = "order by #{order_col} #{dir}"
      sql = ["#{sel} where #{cond} #{order} #{limits}"]
      sql = sql + vals

      works = Work.find_by_sql(sql)
      filter_cond = [cond]+vals
      filtered_cnt = Work.count(:conditions => filter_cond)
      
      data = []
      works.each do |work|
         if work.ocr_results.count == 0
            rec = work_to_hash(work)   
            data << rec 
         else
            work.ocr_results.each do |ocr|
               rec = work_to_hash(work)  
               rec[:ocr_date] = ocr.ocr_completed.to_datetime.strftime("%m/%d/%Y %H:%M")
               rec[:ocr_engine] = OcrEngine.find(ocr.ocr_engine_id ).name
               rec[:ocr_batch] = "#{ocr.batch_id}: #{ocr.batch_name}"
               rec[:juxta_url] = gen_pages_link(work.wks_work_id, ocr.batch_id, ocr.juxta_accuracy)
               rec[:retas_url] = gen_pages_link(work.wks_work_id, ocr.batch_id, ocr.retas_accuracy)
               data << rec      
            end
         end
      end
            
      resp['data'] = data
      resp['iTotalDisplayRecords'] = filtered_cnt
      render :json => resp, :status => :ok
   end
  
      
   private
   def work_to_hash(work)
     rec = {}
      if work.isECCO?
         rec[:data_set] = 'ECCO'
      else
         rec[:data_set] = 'EEBO'   
      end 
      rec[:tcp_number] = work.wks_tcp_number
      rec[:title] = work.wks_title
      rec[:author] = work.wks_author
      rec[:ocr_date] = nil
      rec[:ocr_engine] = nil
      rec[:ocr_batch] = nil
      rec[:juxta_accuracy] = nil
      rec[:retas_accuracy] = nil
      rec[:juxta_url] = nil
      rec[:retas_url] = nil
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
