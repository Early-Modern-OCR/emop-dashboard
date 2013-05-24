class DashboardController < ApplicationController
   # main dashboard summary view
   #
   def index
      # wk = Work.find(151311)
      # puts wk.wks_title
      # wk.pages.each do |page|
         # res = page.page_results.first
         # if !res.nil?
            # puts "Page #{page.pg_ref_number}, Juxta #{res.juxta_change_index}"
         # end
      # end
   end

   # Called from datatable to fetch a subset of data for display
   #
   def fetch
      # Parameters: {"sEcho"=>"1", "iColumns"=>"5", "sColumns"=>"", "iDisplayStart"=>"0", 
      #              "iDisplayLength"=>"10", "mDataProp_0"=>"0", "mDataProp_1"=>"1", "mDataProp_2"=>"2", 
      #              "mDataProp_3"=>"3", "mDataProp_4"=>"4", "sSearch"=>"", "bRegex"=>"false", "sSearch_0"=>"", 
      #              "bRegex_0"=>"false", "bSearchable_0"=>"true", "sSearch_1"=>"", "bRegex_1"=>"false", 
      #              "bSearchable_1"=>"true", "sSearch_2"=>"", "bRegex_2"=>"false", "bSearchable_2"=>"true", 
      #              "sSearch_3"=>"", "bRegex_3"=>"false", "bSearchable_3"=>"true", "sSearch_4"=>"", "bRegex_4"=>"false", 
      #              "bSearchable_4"=>"true", "iSortCol_0"=>"0", "sSortDir_0"=>"asc", "iSortingCols"=>"1", "bSortable_0"=>"true", 
      #              "bSortable_1"=>"true", "bSortable_2"=>"true", "bSortable_3"=>"true", "bSortable_4"=>"true", "_"=>"1369403058236"}
      
      resp = {}
      resp['sEcho'] = params[:sEcho]
      resp['iTotalRecords'] = Work.count(:wks_tcp_number)
      
      sort_col = params[:iSortCol_0]
      sort_dir = params[:sSortDir_0]
      cols = ['wks_ecco_number', 'wks_tcp_number', 'wks_title', 'wks_author']
      order = "#{cols[sort_col.to_i]} #{sort_dir}" 
      
      data = []
      works = Work.find(:all, :offset => params[:iDisplayStart], :limit => params[:iDisplayLength], 
                        :conditions => ["wks_tcp_number is not null"], :order => order )
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
         
         rec << 0.9 # gale / juxta
         rec << 0.7 # curr / juxta
         rec << 0.9 # gale retas
         rec << 0.75 # curr retas
         
         data << rec 
      end
      resp['data'] = data
      resp['iTotalDisplayRecords'] = Work.count(:wks_tcp_number)
      
      
      render :json => resp, :status => :ok
      
   end
end
