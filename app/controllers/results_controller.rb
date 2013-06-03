class ResultsController < ApplicationController
   # show the page details for the specified work
   #
   def show
      # TODO get summary data to show above page results table
      @work_id = params[:work]
      @batch_id = params[:batch]
      work = Work.find(@work_id)
      @work_title=work.wks_title
      
      batch = BatchJob.find(@batch_id)
      @batch = "#{batch.id}: #{batch.name}"
      
   end

   # Fetch data for dataTable
   #
   def fetch
      puts params
      
      work_id = params[:work]
      batch_id = params[:batch]
      
      resp = {}
      resp['sEcho'] = params[:sEcho]
      
      sql = ["select count(*) as cnt from page_results inner join pages on page_id=pg_page_id where batch_id=? and pg_work_id=?"]
      sql = sql << batch_id
      sql = sql << work_id
      resp['iTotalRecords'] = PageResult.find_by_sql(sql).first.cnt
      resp['iTotalDisplayRecords'] = resp['iTotalRecords']
     
      # generate order info based on params
      search_col_idx = params[:iSortCol_0].to_i
      cols = [nil,'pg_ref_number','page_results.juxta_change_index','page_results.alt_change_index']
      dir = params[:sSortDir_0]
      order_col = cols[search_col_idx]
      order_col = cols[1] if order_col.nil?
      
      # get results and transform them into req'd json structure
      data = []
      results = Page.joins(:page_results).where(:pg_work_id => work_id, :page_results => {:batch_id => batch_id}).order("#{order_col} #{dir}")
      results.each do | result | 
         rec = {}
         rec[:detail_link] = "<div class='detail-link'></div>"
         rec[:page_number] = result.pg_ref_number
         rec[:juxta_accuracy] = result.page_results.first.juxta_change_index
         rec[:retas_accuracy] = result.page_results.first.alt_change_index
         data << rec
      end
      
      resp['data'] = data
      render :json => resp, :status => :ok

   end

end
