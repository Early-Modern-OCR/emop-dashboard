module Api
  module V1
    class BatchJobsController < V1::BaseController

      api :GET, '/batch_jobs', 'List batch jobs'
      param_group :pagination, V1::BaseController
      def index
        super
      end

      api :GET, '/batch_jobs/:id', 'Show a batch job'
      param :id, /^[0-9]+$/, desc: "Batch job ID", required: true
      def show
        super
      end

      api :GET, '/batch_jobs/count', 'Count of batch jobs'
      def count
        @count = BatchJob.count(:all)
        respond_with @count
      end

      private

      def batch_job_params
        params.require(:batch_job).permit()
      end

      def query_params
        params.permit()
      end

    end
  end
end
