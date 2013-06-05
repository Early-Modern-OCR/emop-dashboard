class ResultsController < ApplicationController
   # show the page details for the specified work
   #
   def show
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
         rec[:detail_link] = "<a href='/juxta?work=#{work_id}&batch=#{batch_id}&result=#{ result.page_results.first.id}'><div class='detail-link'></div></a>"
         rec[:page_number] = result.pg_ref_number
         rec[:juxta_accuracy] = result.page_results.first.juxta_change_index
         rec[:retas_accuracy] = result.page_results.first.alt_change_index
         rec[:page_image] = "<a href=\"/results/#{work_id}/page/#{result.pg_ref_number}\">View</a>"

         data << rec
      end
      
      resp['data'] = data
      render :json => resp, :status => :ok

   end
   
   def get_page_image
      work_id = params[:work]
      page_num = params[:num]   
      work = Work.find(work_id)
      img_path = get_ocr_image_path(work, page_num)
      send_file img_path, type: "image/tiff", disposition: "inline"
   end
   
   private
   def get_ocr_image_path(work, page_num) 
      if work.isECCO?
         # ECCO format: ECCO number + 4 digit page + 0.tif
         ecco_dir = work.wks_ecco_directory
         return "%s%s/images/%s%04d0.TIF" % [Settings.emop_path_prefix, ecco_dir, work.wks_ecco_number, page_num];
      else
         # EEBO format: 00014.000.001.tif where 00014 is the page number.
         ebbo_dir = work.wks_eebo_directory
         return "%s%s/%05d.000.001.tif", [Settings.emop_path_prefix, ebbo_dir, page_num];
      end
   end

end
