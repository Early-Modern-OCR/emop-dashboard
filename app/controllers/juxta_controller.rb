class JuxtaController < ApplicationController
  
  # show a juxta sbs view of the specified OCR result vs ground truth
  #
  def show
     result_id = params[:result]
     @work_id = params[:work]
     @batch_id = params[:batch]
     puts result_id
  end
end
