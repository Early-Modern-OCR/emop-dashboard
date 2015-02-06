class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private

  def redirect_to_referrer
    session[:return_to] ||= request.referer
    redirect_to session.delete(:return_to)
  end
end
