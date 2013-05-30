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
      
      q = params[:sSearch]
      cond = ["wks_tcp_number is not null"]
      if q.length > 0 
         qs = "wks_tcp_number is not null && (wks_tcp_number LIKE ? || wks_author LIKE ? || wks_title LIKE ?)"
         cond = [qs, "%#{q}%", "%#{q}%", "%#{q}%" ]   
      end
      
      data = []
      works = Work.find(:all, :offset => params[:iDisplayStart], :limit => params[:iDisplayLength], :conditions => cond )
      filtered_cnt = Work.count(:conditions => cond)
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
               rec[:juxta_accuracy] = ocr.juxta_accuracy.to_s
               rec[:juxta_url] = gen_pages_link(work.wks_work_id, ocr.batch_id, ocr.juxta_accuracy)
               rec[:retas_accuracy] = ocr.retas_accuracy.to_s#gen_pages_link(work.wks_work_id, ocr.batch_id, ocr.retas_accuracy)
               rec[:retas_url] = gen_pages_link(work.wks_work_id, ocr.batch_id, ocr.retas_accuracy)
               data << rec      
            end
         end
      end
      
      data = sort_results(data, params[:iSortCol_0].to_i, params[:sSortDir_0])
      
      resp['data'] = data
      resp['iTotalDisplayRecords'] = filtered_cnt
      render :json => resp, :status => :ok
   end
   
   private
   def sort_results(data, col, dir)
      cols = [nil,:tcp_number, :title, :author, :ocr_date, :ocr_engine, nil, :juxta_accuracy,:retas_accuracy ]
      sort_field = cols[col]
      sort_field = :tcp_number if sort_field.nil?
      data = data.sort_by{ |a| a[sort_field] || "" }
      if dir == 'desc'
         data.reverse!
      end
      return data
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
      formatted = '%.2f'%accuracy
      out = "<a href='page/#{work_id}?batch=#{batch_id}' #{link_class}>#{formatted}</a>"
      return out   
   end

end
