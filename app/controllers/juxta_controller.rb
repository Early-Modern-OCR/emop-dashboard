require 'rest_client'

class JuxtaController < ApplicationController
   
   # show a juxta sbs view of the specified OCR result vs ground truth
   #
   def show
      @result_id = params[:result]
      @work_id = params[:work]
      @batch_id = params[:batch]

      # see if a collation exists for this result vs GT
      collation = JuxtaCollation.where(:page_result_id => @result_id).first
      if collation.nil?
         # create a new collation if one doesn't exist.
         # status will be created
         collation = JuxtaCollation.new(:page_result_id => @result_id)
      collation.save!
      end

      # save key info about the collation needed by the view
      @collation_id = collation.id
      @collation_status = collation.status
   end

   # Create a new juxta collation
   #
   def create
      work_id = params[:work]
      batch_id = params[:batch]
      collation_id = params[:collation]
      collation = JuxtaCollation.find( collation_id )
      result = PageResult.find( collation.page_result_id )

      begin
         # upload sources
         gt_file = result.page.pg_ground_truth_file
         ocr_file = result.ocr_text_path
         gt_id, ocr_id = create_jx_sources( gt_file, ocr_file)
         collation.jx_gt_source_id = gt_id
         collation.jx_ocr_source_id = ocr_id
         collation.save!

         # create witnesses
         gt_wit_id, ocr_wit_id = create_jx_witnesses( gt_id, gt_file, ocr_id, ocr_file )
         
         # create a set with the witnesses, and set collation settings
         set_name = "#{work_id}.#{batch_id}.#{result.page.pg_ref_number}"
         set_id = create_jx_set(set_name, gt_wit_id, ocr_wit_id)
         collation.jx_set_id = set_id
         collation.save!
         
         # collate it
         query = "#{Settings.juxta_ws_url}/set/#{set_id}/collate"
         resp = RestClient.post query, '', :content_type => "application/json", :authorization => Settings.auth_token
         done = false
         query = "#{Settings.juxta_ws_url}/task/#{resp}/status"
         while done == false do
            sleep 1
            status = JSON.parse(RestClient.get query, :authorization => Settings.auth_token)
            done = (status['status'] == 'COMPLETE')
         end
         
         collation.status = :ready
         collation.save!

         render :text => "ok", :status => :ok
      rescue RestClient::Exception => rest_error
         render :text => rest_error.response, :status => rest_error.http_code
      rescue Exception => e
         render :text => e, :status => :internal_server_error
      end
   end

   # Create a jx comparison set with the witnesses
   #
   private
   def create_jx_set( name, gt_wit_id, ocr_wit_id) 
      jx_exist_url = "#{Settings.juxta_ws_url}/set/exist?name=#{name}"
      resp = RestClient.get jx_exist_url, :authorization => Settings.auth_token
      json_resp = ActiveSupport::JSON.decode( resp )
      if json_resp['exists'] 
         return json_resp['id']
      end
      
      jx_set_query = "#{Settings.juxta_ws_url}/set"
      data = {}
      data['name'] = name
      data['witnesses'] = [gt_wit_id, ocr_wit_id]
      json_data = ActiveSupport::JSON.encode( data )
      resp = RestClient.post jx_set_query, json_data, :content_type => "application/json", :authorization => Settings.auth_token
      set_id = resp.gsub(/\"/, "")
      
      # now set the collator settings
      data = { :filterWhitespace=>true, :filterPunctuation=>true,:filterCase=>true,:hyphenationFilter=>"FILTER_ALL" }
      json_data = ActiveSupport::JSON.encode( data )
      jx_set_query = "#{Settings.juxta_ws_url}/set/#{set_id}/collator"
      RestClient.post jx_set_query, json_data, :content_type => "application/json", :authorization => Settings.auth_token
   
      return set_id
   end

   # Transform sources into witnesses. Returns [GT witnessID, OCR witnessID]
   #
   private
   def create_jx_witnesses(gt_src_id, gt_file, ocr_src_id, ocr_file)
      gt_name = gt_file.gsub( /.txt/, '' )
      ocr_name = ocr_file.gsub( /.txt/, '' )
      jx_xform_query = "#{Settings.juxta_ws_url}/transform"
      jx_exist_url = "#{Settings.juxta_ws_url}/witness/exist?name="
      data = {}
      
      # witness for GT source
      resp = RestClient.get jx_exist_url+gt_name, :authorization => Settings.auth_token
      json_resp = ActiveSupport::JSON.decode( resp )
      if json_resp['exists'] 
         gt_id = json_resp['id']
      else
         data['source'] = gt_src_id
         data['finalName'] = gt_name
         json_data = ActiveSupport::JSON.encode( data )
         resp = RestClient.post jx_xform_query, json_data, :content_type => "application/json", :authorization => Settings.auth_token
         gt_id =  resp.gsub( /\"/, "" )
      end
      
      # witness for OCR source
      resp = RestClient.get jx_exist_url+ocr_name, :authorization => Settings.auth_token
      json_resp = ActiveSupport::JSON.decode( resp )
      if json_resp['exists'] 
         ocr_id = json_resp['id']
      else
         data['source'] = ocr_src_id
         data['finalName'] = ocr_name
         json_data = ActiveSupport::JSON.encode( data )
         resp = RestClient.post jx_xform_query, json_data, :content_type => "application/json", :authorization => Settings.auth_token
         ocr_id =  resp.gsub( /\"/, "" )
      end
      
      return gt_id, ocr_id
   end

   # upload the GT and OCR sources to JuxtaWS. Returns [GT sourceID, OCR sourceD]
   #
   private
   def create_jx_sources(gt_file, ocr_file)
      data = {}
      data['type'] = "raw"
      data['contentType'] = "txt"
      jx_exist_url = "#{Settings.juxta_ws_url}/source/exist?name="
      jx_url = "#{Settings.juxta_ws_url}/source"
      
      # handle GT source first
      resp = RestClient.get jx_exist_url+gt_file, :authorization => Settings.auth_token
      json_resp = ActiveSupport::JSON.decode( resp )
      if json_resp['exists'] 
         gt_id = json_resp['id']
      else
         data['name'] = gt_file
         data['data'] = File.read("#{Settings.emop_path_prefix}#{gt_file}")
         json_data = ActiveSupport::JSON.encode( [ data ] )
         resp = RestClient.post jx_url, json_data, :content_type => "application/json", :authorization => Settings.auth_token
         json_resp = ActiveSupport::JSON.decode( resp )
         gt_id = json_resp[0]    
      end
      
      # now OCR source
      resp = RestClient.get jx_exist_url+ocr_file, :authorization => Settings.auth_token
      json_resp = ActiveSupport::JSON.decode( resp )
      if json_resp['exists'] 
         ocr_id = json_resp['id']
      else
         data['name'] = ocr_file
         data['data'] = File.read("#{Settings.emop_path_prefix}#{ocr_file}")
         json_data = ActiveSupport::JSON.encode( [ data ] )
         resp = RestClient.post jx_url, json_data, :content_type => "application/json", :authorization => Settings.auth_token
         json_resp = ActiveSupport::JSON.decode( resp )
         gt_id = json_resp[0]    
      end
   
      return gt_id, ocr_id
   end
end
