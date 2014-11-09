module Api
  module V1
    class JobQueuesController < V1::BaseController

      api :GET, '/job_queues', 'List job queues'
      param_group :pagination, V1::BaseController
      param :job_status, /^[0-9]+$/, desc: 'Job status ID'
      def index
        super
      end

      api :GET, '/job_queues/:id', 'Show a job queue'
      param :id, /^[0-9]+$/, desc: "Job queue ID", required: true
      def show
        super
      end

      api :GET, '/job_queues/count', 'Count of job queues'
      param :job_status, /^[0-9]+$/, desc: 'Job status ID'
      def count
        @count = JobQueue.where(query_params).count
        respond_with @count
      end

      api :PUT, '/job_queues/reserve', 'Reserve job queues'
      param :job_queue, Hash, required: true do
        param :num_pages, /^[0-9]+$/, desc: 'Number of pages to reserve', required: true
      end
      def reserve
        @num_pages = params['job_queue']['num_pages'].to_i
        @job_queues = JobQueue.unreserved.limit(@num_pages)
        @proc_id = JobQueue.generate_proc_id

        @job_queues.update_all(proc_id: @proc_id, job_status: JobStatus.processing.id)

        respond_with @job_queues
      end

      private

      def job_queue_params
        params.require(:job_queue).permit(:num_pages)
      end

      def query_params
        params.permit(:job_status, :num_pages, :proc_id)
      end

    end
  end
end
