class DashboardController < ApplicationController
   # main dashboard summary view
   #
   def index
      # TODO get data for summary table
   end

   # Called from datatable to fetch a subset of data for display
   #sSearch
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
      works.each do |work|
         rec = []
         if work.isECCO?
            rec << 'ECCO'
         else
            rec << 'EEBO'   
         end 
         rec << work.wks_tcp_number
         rec << work.wks_title
         rec << work.wks_author
         
         jx_gale, rt_gale = calculate_accuracy(:gale, work)
         jx_tess, rt_tess = calculate_accuracy(:tesseract, work)
         
         rec << jx_gale # gale / juxta
         rec << rt_gale # gale / retas
         

         rec << jx_tess# curr / juxta
         rec << jx_gale # curr retas
         
         data << rec 
      end
      resp['data'] = data
      resp['iTotalDisplayRecords'] = Work.count(:wks_tcp_number)
      
      
      render :json => resp, :status => :ok
      
   end
   
   # calculate gale accuracy. return a pair of numbers. first
   # is accuracy according to juxta, second is accuracy accorgind to retas
   #
   private
   def calculate_accuracy( ocr_engine, work )
      
      juxta_total=0.0
      retas_total=0.0
      
      if work.wks_work_id == 255142
         puts 'hey'
      end
      
      #K072686.000
      cnt = 0
      work.pages.each do |page|
         latest = page.get_latest_result( ocr_engine )
         if !latest.nil?
            juxta_total = juxta_total + latest.juxta_change_index
            retas_total = retas_total + latest.alt_change_index
            cnt = cnt +1
         else
            return nil,nil
         end
      end
      
      # there is some junk data that has no pages. kill it
      if cnt == 0
         return nil,nil
      end
      
      return  ('%.2f'%(juxta_total/cnt)), ('%.2f'%(retas_total/cnt))
   end
end
