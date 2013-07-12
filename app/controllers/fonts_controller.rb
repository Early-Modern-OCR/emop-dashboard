
class FontsController < ApplicationController
   # Create a training font from the multipart form post
   #
   def create_training_font
      begin
         # grab the uploaded file and write it out
         # to the shared fonts directory
         upload_file = params[:file].tempfile
         orig_name =  params[:file].original_filename
         font_name = params["font-name"]
         out_dir = "#{Settings.emop_font_dir}/#{font_name}"
         out = "#{out_dir}/#{orig_name}"
         if !File.directory?( out_dir )
            Dir.mkdir(out_dir)
         end
         File.open(out, "wb") { |f| f.write(upload_file.read) }
         
         # Create a reference to it in the fonts tabls
         font = Font.new
         font.font_library_path = out
         font.font_name = font_name
         font.save!

         # send back the new font as a json object so it can
         # be added to the relevant dropdown lists
         render :json => ActiveSupport::JSON.encode(font), :status => :ok
      rescue => e
         render :text => e.message, :status => :error
      end
   end
   
      
   # Set the print font on the works contained in th ePOST payload
   #
   def set_print_font
      begin 
         font_id = params[:font_id]
         if font_id.length == 0
            font_id=nil
         end
         works = params[:works].gsub(/\"/,'')
         works = works.gsub( /\[/, '(').gsub( /\]/, ')')
         sql = "update works set wks_primary_print_font=#{ActiveRecord::Base.sanitize(font_id)} where wks_work_id in #{works}"
         PrintFont.connection.execute( sql)
         render :text => "ok", :status => :ok
      rescue => e
         render :text => e.message, :status => :error
      end 
   end
end
