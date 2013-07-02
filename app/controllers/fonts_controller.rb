
class FontsController < ApplicationController
   # Create a training font from the multipart form post
   #
   def create
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
         
         # TODO This wont work on current production; ID is not autoimcrement
         # if this doesnt change, need to grab the latest entry from the
         # table_keys table, increment it, add it to the font and update
         # the recent index in the table_keys table

         # send back the new font as a json object so it can
         # be added to the relevant dropdown lists
         render :json => ActiveSupport::JSON.encode(font), :status => :ok
      rescue => e
         render :text => e.message, :status => :error
      end
   end
end
