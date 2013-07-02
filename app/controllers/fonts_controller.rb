class FontsController < ApplicationController
  # Create a training font from the multipart form post
  #
  def create
     logger.info "CREATE"
     render :text => "NO", :status => :error
  end
end
