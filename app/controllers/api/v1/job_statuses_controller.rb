module Api
  module V1
    class JobStatusesController < V1::BaseController

      api :GET, '/job_statuses', 'List job statuses'
      param :name, String, desc: 'Status name'
      def index
        super
      end

      api :GET, '/job_statuses/:id', 'Show a job status'
      param :id, Integer, desc: 'Status ID', required: true
      def show
        super
      end

      private

      def query_params
        params.permit(:id, :name)
      end

      def page_params
        params.permit()
      end
    end
  end
end
