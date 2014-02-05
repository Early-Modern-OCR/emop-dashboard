module Api
  module V1
    class BaseController < Api::BaseController
      resource_description do
        api_version "v1"
      end
    end
  end  
end
