module Api
  module V2
    class JobStatusesController < V2::BaseController

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
    end
  end
end
