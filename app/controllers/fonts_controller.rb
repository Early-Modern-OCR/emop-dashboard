
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
         
         # get a new key for the new font from the table_keys
         key_info = TableKey.find(:first, :conditions => [ "tk_table = ?", "fonts"])
         if key_info.nil?
            key_info = TableKey.new
            key_info.tk_table = "fonts"
            last_id = Font.find_by_sql("select font_id from fonts order by font_id desc limit 1").first.font_id
            key_info.tk_key = last_id+1
         else
            key_info.tk_key = key_info.tk_key+1
         end
         key_info.save!
         
         # Create a reference to it in the fonts tabls
         font = Font.new
         font.font_id = key_info.tk_key
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
end
