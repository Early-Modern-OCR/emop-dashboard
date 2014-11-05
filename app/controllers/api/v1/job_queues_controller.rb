module Api
  module V1
    class JobQueuesController < V1::BaseController

      api :GET, "/job_queues", "List job queues"
      param_group :pagination, V1::BaseController
      def index
        super
      end

      api :GET, '/job_queues/:id', 'Show a job queue'
      param :id, Fixnum, desc: "Job queue ID", required: true
      def show
        super
      end

      api :GET, '/job_queues/count', 'Count of job queues'
      def count
        @count = JobQueue.count(:all)
        respond_with @count
      end

      private

      def job_queue_params
        params.require(:job_queue).permit()
      end

      def query_params
        params.permit(:proc_id)
      end

    end
  end
end
