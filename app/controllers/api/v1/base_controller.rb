module Api
  module V1
    class BaseController < Api::BaseController
      before_action :set_resource, only: [:destroy, :show, :update]

      resource_description do
        api_version 'v1'
      end

      layout 'api/v1/layouts/index_layout', :only => :index

      def_param_group :pagination do
        param :page, String, :desc => 'paginate results'
        param :page_size, String, :desc => 'number of entries per request'
      end

      helper_method :root_node_name, :metadata_total, :metadata_subtotal,
                    :metadata_page, :metadata_per_page, :metadata_total_pages

      def root_node_name
        'results'
      end

      def metadata_total
        @total ||= instance_variable_get("@#{resource_name.pluralize}").try(:total_count)
      end

      def metadata_subtotal
        @subtotal ||= instance_variable_get("@#{resource_name.pluralize}").try(:count)
      end

      def metadata_page
        @page ||= page_params[:page].present? ? page_params[:page].to_i : 1
      end

      def metadata_per_page
        per_page ||= page_params[:per_page].present? ? page_params[:per_page].to_i : resource_class.try(:default_per_page).to_i
        if per_page > @total
          per_page = @total
        end
        @per_page = per_page
      end

      def metadata_total_pages
        @total_pages ||= instance_variable_get("@#{resource_name.pluralize}").try(:total_pages)
      end

      # POST /api/{plural_resource_name}
      def create
        set_resource(resource_class.new(resource_params))

        if get_resource.save
          render :show, status: :created
        else
          render json: get_resource.errors, status: :unprocessable_entity
        end
      end

      # DELETE /api/{plural_resource_name}/1
      def destroy
        get_resource.destroy
        head :no_content
      end

      # GET /api/{plural_resource_name}
      def index
        plural_resource_name = "@#{resource_name.pluralize}"
        resources = resource_class.where(query_params)
                                  .page(page_params[:page]).per(page_params[:per_page])

        #instance_variable_set('@total', resources.length)
        instance_variable_set(plural_resource_name, resources)
        respond_with instance_variable_get(plural_resource_name)
      end

      # GET /api/{plural_resource_name}/1
      def show
        respond_with get_resource
      end

      # PATCH/PUT /api/{plural_resource_name}/1
      def update
        if get_resource.update(resource_params)
          render :show
        else
          render json: get_resource.errors, status: :unprocessable_entity
        end
      end

      private

      # Returns the resource from the created instance variable
      # @return [Object]
      def get_resource
        instance_variable_get("@#{resource_name}")
      end

      # Returns the allowed parameters for searching
      # Override this method in each API controller
      # to permit additional parameters to search on
      # @return [Hash]
      def query_params
        {}
      end

      # Returns the allowed parameters for pagination
      # @return [Hash]
      def page_params
        params.permit(:page, :per_page)
      end

      # The resource class based on the controller
      # @return [Class]
      def resource_class
        @resource_class ||= resource_name.classify.constantize
      end

      # The singular name for the resource class based on the controller
      # @return [String]
      def resource_name
        @resource_name ||= self.controller_name.singularize
      end

      # Only allow a trusted parameter "white list" through.
      # If a single resource is loaded for #create or #update,
      # then the controller for the resource must implement
      # the method "#{resource_name}_params" to limit permitted
      # parameters for the individual model.
      def resource_params
        @resource_params ||= self.send("#{resource_name}_params")
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_resource(resource = nil)
        resource ||= resource_class.find(params[:id])
        instance_variable_set("@#{resource_name}", resource)
      end
    end
  end
end
