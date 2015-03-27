module Api
  class BaseController < ActionController::Base
    protect_from_forgery with: :null_session
    respond_to :json

    prepend_before_filter :disable_devise_trackable
    before_filter :authenticate_user_from_token!

    rescue_from(Apipie::ParamInvalid) do |param_invalid_exception|
      response = { error: param_invalid_exception.to_s }
      respond_to do |format|
        format.json { render json: response, status: :unprocessable_entity }
      end
    end

    protected

    def disable_devise_trackable
      request.env["devise.skip_trackable"] = true
    end

    private

    def authenticate_user_from_token!
      user  = nil

      authenticate_or_request_with_http_token do |token, options|
        user = User.find_by(auth_token: token)
      end

      if user
        sign_in user, store: false
      end
    end
  end
end
