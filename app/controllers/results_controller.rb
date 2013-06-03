class ResultsController < ApplicationController
   # show the page details for the specified work
   #
   def show
      # TODO get summary data to show above page results table
      @work_id = params[:work]
      @batch_id = params[:batch]
      
      puts "SHOW PAGE RESULTS"
   end

   # Fetch data for dataTable
   #
   def fetch
      puts "FETCH PAGE RESULTS"
      puts params
      
      work_id = params[:work]
      batch_id = params[:batch]
      
      resp = {}
      resp['sEcho'] = params[:sEcho]
      
      sql = ["select count(*) as cnt from page_results inner join pages on page_id=pg_page_id where batch_id=? and pg_work_id=?"]
      sql = sql << batch_id
      sql = sql << work_id
      resp['iTotalRecords'] = PageResult.find_by_sql(sql).first.cnt
      data = []
      results = Page.joins(:page_results).where(:pg_work_id => work_id, :page_results => {:batch_id => batch_id})
      results.each do | result | 
         rec = {}
         rec[:page_number] = result.pg_ref_number
         rec[:juxta_accuracy] = result.page_results.first.juxta_change_index
         rec[:retas_accuracy] = result.page_results.first.alt_change_index
         data << rec
      end
      
      resp['data'] = data
      resp['iTotalDisplayRecords'] = resp['iTotalRecords']
      render :json => resp, :status => :ok

   end

end
