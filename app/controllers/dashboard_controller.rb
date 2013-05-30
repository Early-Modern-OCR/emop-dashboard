class DashboardController < ApplicationController
   # main dashboard summary view
   #
   def index
      # TODO get data for summary table
   end

   # Called from datatable to fetch a subset of data for display
   #
   def fetch
      puts params
      resp = {}
      resp['sEcho'] = params[:sEcho]
      resp['iTotalRecords'] = Work.count(:wks_tcp_number)
      
      sort_col = params[:iSortCol_0]
      sort_dir = params[:sSortDir_0]
      cols = ['wks_ecco_number', 'wks_tcp_number', 'wks_title', 'wks_author']
      order = "#{cols[sort_col.to_i]} #{sort_dir}" 
      
      q = params[:sSearch]
      cond = ["wks_tcp_number is not null"]
      if q.length > 0 
         qs = "wks_tcp_number is not null && (wks_tcp_number LIKE ? || wks_author LIKE ? || wks_title LIKE ?)"
         cond = [qs, "%#{q}%", "%#{q}%", "%#{q}%" ]   
      end
      
      data = []
      works = Work.find(:all, :offset => params[:iDisplayStart], :limit => params[:iDisplayLength], 
                        :conditions => cond, :order => order )
      filtered_cnt = Work.count(:conditions => cond)
      works.each do |work|
         if work.ocr_results.count == 0
            rec = work_to_array(work)   
            rec << nil
            rec << nil
            rec << nil
            rec << nil
            rec << nil
            data << rec 
         else
            work.ocr_results.each do |ocr|
               rec = work_to_array(work)
               rec <<  ocr.ocr_completed.to_datetime.strftime("%m/%d/%Y %H:%M")
               rec << OcrEngine.find(ocr.ocr_engine_id ).name
               rec << "#{ocr.batch_id}: #{ocr.batch_name}"
               rec << gen_pages_link(work.wks_work_id, ocr.batch_id, ocr.juxta_accuracy)
               rec << gen_pages_link(work.wks_work_id, ocr.batch_id, ocr.retas_accuracy)
               data << rec      
            end
         end
      end
      
      resp['data'] = data
      resp['iTotalDisplayRecords'] = filtered_cnt
      render :json => resp, :status => :ok
   end
    
   def work_to_array(work)
     rec = []
      if work.isECCO?
         rec << 'ECCO'
      else
         rec << 'EEBO'   
      end 
      rec << work.wks_tcp_number
      rec << work.wks_title
      rec << work.wks_author
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
      formatted = '%.2f'%accuracy
      out = "<a href='page/#{work_id}?batch=#{batch_id}' #{link_class}>#{formatted}</a>"
      return out   
   end

end
