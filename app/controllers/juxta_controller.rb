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
  
  # upload GT and OCR source text to JuxtaWS (this is called with ajax from client)
  #
  def upload_sources
      collation_id = params[:collation_id] 
      collation = JuxtaCollation.find( collation_id )
      result = PageResult.find( collation.page_result_id )

      #begin
         # send GT file to juxtaWS
         gt_file = result.page.pg_ground_truth_file
         data = {}
         data['type'] = "raw"
         data['contentType'] = "txt"
         data['name'] = gt_file
         data['data'] = File.read("#{Settings.emop_path_prefix}#{gt_file}")
         req_array = [ data ]
         json_data = ActiveSupport::JSON.encode( req_array )
         jx_url = "#{Settings.juxta_ws_url}/source"
         resp = RestClient.post jx_url, json_data, :content_type => "application/json", :authorization => Settings.auth_token
         
         # get the ID from the response and save it for updating the local database
         json_resp = ActiveSupport::JSON.decode( resp )
         collation.jx_gt_source_id = json_resp[0]
         
         # set OCR file to JuxtaWS
         ocr_file = result.ocr_text_path
         data['name'] = ocr_file
         data['data'] = File.read("#{Settings.emop_path_prefix}#{ocr_file}")
         req_array = [ data ]
         json_data = ActiveSupport::JSON.encode( req_array )
         resp = RestClient.post jx_url, json_data, :content_type => "application/json", :authorization => Settings.auth_token
          
         # get the ID from the response and save it for updating the local database
         json_resp = ActiveSupport::JSON.decode( resp )
         collation.jx_ocr_source_id = json_resp[0]
         
         # update the juxta_collations record with the jx source ids
         collation.save!
         
         render :json => "NO", :status => :ok  
      # rescue RestClient::Exception => rest_error
         # render :text => rest_error.response, :status => rest_error.http_code
      # rescue Exception => e
         # render :text => e, :status => :internal_server_error
      # end
  end
end
