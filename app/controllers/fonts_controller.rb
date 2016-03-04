class FontsController < ApplicationController
  # Create a training font from the multipart form post
  #
  def create_training_font
    font_name = params['font-name']
    if Font.exists?(font_name: font_name)
      render text: 'A font with this name already exists. Please use a unique name.', status: :error
      return
    end

    # grab the uploaded file and write it out
    # to the shared fonts directory
    upload_file = params[:file].tempfile

    @font = Font.new(font_name: font_name, font_library_path: nil)
    @font.path = @font.traineddata_path

    # Write the font's traineddata file
    File.open(@font.traineddata_path, 'wb') { |f| f.write(upload_file.read) }

    @font.save!

    # send back the new font as a json object so it can
    # be added to the relevant dropdown lists
    render json: ActiveSupport::JSON.encode(@font), status: :ok
  rescue => e
    logger.error("FontsController#create_training_font: #{e.message}")
    render text: e.message, status: :error
  end

  # Set the print font on the works contained in th ePOST payload
  #
  def set_print_font
    if params.key?(:new_font)
      @print_font = PrintFont.create!(pf_name: params[:new_font])
    else
      # This query and first_or_initialize ensure that @print_font.id is nil when
      # a value like '' is used (for None in dropdown)
      @print_font = PrintFont.where(pf_id: params[:font_id]).first_or_initialize
    end

    works = ActiveSupport::JSON.decode(params[:works])
    Work.where(wks_work_id: works).update_all(wks_primary_print_font: @print_font.id)
    render text: 'ok', status: :ok
  rescue => e
    logger.error("FontsController#set_print_font: #{e.message}")
    render text: e.message, status: :error
  end
end
