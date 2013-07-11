class ResultsController < ApplicationController
   # show the page details for the specified work
   #
   def show
      @work_id = params[:work]
      @batch_id = params[:batch]
      work = Work.find(@work_id)
      @work_title=work.wks_title
      
      if !@batch_id.nil?
         batch = BatchJob.find(@batch_id)
         @batch = "#{batch.id}: #{batch.name}"
      else 
         @batch = "Not Applicable"   
      end
   end

   # Fetch data for dataTable
   #
   def fetch
      puts params
      
      work_id = params[:work]
      batch_id = params[:batch]
      if batch_id.nil? || batch_id.length == 0
         render_page_info(work_id)
      else
         render_batch_results(work_id, batch_id)
      end
   end
   
   # Render pages table without batch results
   #
   def render_page_info(work_id)
      resp = {}
      resp['sEcho'] = params[:sEcho]
      
      sql = ["select count(*) as cnt from pages where pg_work_id=?"]
      sql = sql << work_id
      cnt = PageResult.find_by_sql(sql).first.cnt
      resp['iTotalRecords'] = cnt
      resp['iTotalDisplayRecords'] = resp['iTotalRecords']
     
      # only order by page number here.. thats all thats available
      dir = params[:sSortDir_0]
      dir = "asc" if dir.nil?
      order_col = "pg_ref_number"
      
      sql = ["select pg_ref_number as page_num, pg_page_id as page_id from pages where pg_work_id=?", work_id]
      pages = Page.find_by_sql(sql)
      
      # get results and transform them into req'd json structure
      data = []
      pages.each do | page |
         rec = {}
         rec[:page_select] = "<input class='sel-cb' type='checkbox' id='sel-page-#{page.page_id}'>"
         rec[:detail_link] = "<div class='detail-link disabled'>"  # no details yet!
         rec[:status] = page_status_icon(page.page_id, nil, nil)
         rec[:page_number] = page.page_num
         rec[:juxta_accuracy] = "-"
         rec[:retas_accuracy] = "-"
         rec[:page_image] = "<a href=\"/results/#{work_id}/page/#{page.page_num}\"><div title='View page image' class='page-view'></div></a>"

         data << rec
      end
      
      resp['data'] = data
      render :json => resp, :status => :ok    
   end
   
   # Render the pages table including batch results
   #
   def render_batch_results(work_id, batch_id)
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
      dir = "asc" if dir.nil?
      order_col = cols[search_col_idx]
      order_col = cols[1] if order_col.nil?
      
      # get results and transform them into req'd json structure
      data = []
      sel =  "select pages.pg_ref_number as page_num,pages.pg_page_id as page_id,"
      sel << " page_results.id as result_id, page_results.juxta_change_index as juxta,"
      sel << " page_results.alt_change_index as retas, job_status"
      from =  "FROM pages"
      from << " INNER JOIN page_results ON page_results.page_id = pages.pg_page_id"
      from << " INNER JOIN job_queue ON page_results.page_id = job_queue.page_id and page_results.batch_id = job_queue.batch_id"
      cond = "where page_results.batch_id=? and pg_work_id=?"
      order = "order by #{order_col} #{dir}"
      sql = ["#{sel} #{from} #{cond} #{order}", batch_id, work_id]
      pages = Page.find_by_sql( sql )
      msg = "View side-by-side comparison with GT"
      pages.each do | page | 
         rec = {}
         rec[:page_select] = "<input class='sel-cb' type='checkbox' id='sel-page-#{page.page_id}'>"
         rec[:ocr_text] = "<div id='result-#{page.result_id}' class='ocr-txt' title='View OCR text output'>"  # no details yet!
         if page.juxta.nil?
            rec[:juxta_accuracy] = "N/A"
            rec[:retas_accuracy] = "N/A"
            rec[:detail_link] = "<div class='juxta-link disabled'>"  # no details yet!
         else
            rec[:juxta_accuracy] = page.juxta
            rec[:retas_accuracy] = page.retas
            rec[:detail_link] = "<a href='/juxta?work=#{work_id}&batch=#{batch_id}&page=#{page.page_num}&result=#{ page.result_id}' title='#{msg}'><div class='juxta-link'></div></a>"
         end
         rec[:status] = page_status_icon(page.page_id, batch_id, page.job_status.to_i)
         rec[:page_number] = page.page_num
         rec[:page_image] = "<a href=\"/results/#{work_id}/page/#{page.page_num}\"><div title='View page image' class='page-view'></div></a>"

         data << rec
      end
      
      resp['data'] = data
      render :json => resp, :status => :ok
   end
   
   # Get the OCR text result for the specified page_result
   #
   def get_page_text
      page_id = params[:id]
      sql = ["select pg_ref_number, ocr_text_path from page_results inner join pages on pg_page_id=page_id where id=?",page_id]
      page_result = PageResult.find_by_sql( sql ).first
      txt_path = "#{Settings.emop_path_prefix}#{page_result.ocr_text_path}"
      file = File.open(txt_path, "r")
      contents = file.read
      resp = {}
      resp[:page] = page_result.pg_ref_number
      resp[:content] = contents
      render  :json => resp, :status => :ok  
   end
   
   # Get the error for a page
   #
   def get_page_error
      page_id = params[:page]
      batch_id = params[:batch]
      sql = ["select pg_ref_number, results from job_queue inner join pages on pg_page_id=page_id where page_id=? and batch_id=?",page_id,batch_id]
      job = JobQueue.find_by_sql( sql ).first
      out = {}
      out[:page] = job.pg_ref_number
      out[:error] = job.results
      render  :json => out, :status => :ok     
   end
   
   # Create a new batch from json data in the POST payload
   #
   def create_batch
      begin
         # create the new batch
         batch = BatchJob.new
         batch.name = params[:name]
         batch.job_type = params[:type_id]
         batch.ocr_engine_id = params[:engine_id]
         batch.font_id = params[:font_id]
         batch.parameters = params[:params]
         batch.notes = params[:notes]
         batch.save!
         
         # populate it with pages from the selected works
         pages =  ActiveSupport::JSON.decode(params[:pages])
         pages.each do | page_id |   
            job = JobQueue.new
            job.batch_id = batch.id
            job.page_id = page_id 
            job.job_status = 1  
            job.save!
         end
         
         render  :text => "ok", :status => :ok  
         
      rescue => e
         render :text => e.message, :status => :error
      end 
   end
   
   def get_page_image
      work_id = params[:work]
      page_num = params[:num]   
      work = Work.find(work_id)
      img_path = get_ocr_image_path(work, page_num)
      #send_file img_path, type: "image/tiff", :stream => false, disposition: "inline", :x_sendfile=>true
      File.open(img_path, 'rb') do |f|
       send_data f.read, :type => "image/tiff", :disposition => "inline", :x_sendfile=>true
      end
   end
   
   private
   def page_status_icon( page_id, batch_id, job_status )
      if job_status.nil?
         if batch_id.nil?
            sql = ["select job_status from job_queue where page_id=?", page_id]
            res = JobQueue.find_by_sql(sql).first
            job_status = res.job_status if !res.nil?
         else
            sql = ["select job_status from job_queue where page_id=? and batch_id=?", page_id,batch_id]
            res = JobQueue.find_by_sql(sql).first
            job_status = res.job_status if !res.nil?
         end
      end
      
      status = "idle"
      msg = "Untested"
      id = nil
      if job_status ==1 || job_status ==2
         status = "scheduled"
         msg = "OCR jobs are scheduled"  
      elsif job_status==6
         status = "error"
         msg = "OCR jobs have failed"
         id = "id='status-#{batch_id}-#{page_id}'"
      elsif job_status == 3 || job_status == 4 || job_status == 5 
         status = "success"
         msg = "Success"
      end
      return "<div #{id} class='status-icon #{status}' title='#{msg}'></div>"
   end
   
   private
   def get_ocr_image_path(work, page_num) 
      if work.isECCO?
         # ECCO format: ECCO number + 4 digit page + 0.tif
         ecco_dir = work.wks_ecco_directory
         return "%s%s/%s%04d0.TIF" % [Settings.emop_path_prefix, ecco_dir, work.wks_ecco_number, page_num];
      else
         # EEBO format: 00014.000.001.tif where 00014 is the page number.
         ebbo_dir = work.wks_eebo_directory
         return "%s%s/%05d.000.001.tif" % [Settings.emop_path_prefix, ebbo_dir, page_num];
      end
   end

end
