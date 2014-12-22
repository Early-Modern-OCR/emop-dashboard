module Api
  module V1
    class JobQueuesController < V1::BaseController

      api :GET, '/job_queues', 'List job queues'
      param_group :pagination, V1::BaseController
      param :job_status_id, Integer, desc: 'Job status ID'
      def index
        super
      end

      api :GET, '/job_queues/:id', 'Show a job queue'
      param :id, Integer, desc: "Job queue ID", required: true
      def show
        super
      end

      api :GET, '/job_queues/count', 'Count of job queues'
      param :job_status_id, Integer, desc: 'Job status ID'
      def count
        @count = JobQueue.where(query_params).count
        respond_with @count
      end

      api :PUT, '/job_queues/reserve', 'Reserve job queues'
      param :job_queue, Hash, required: true do
        param :num_pages, Integer, desc: 'Number of pages to reserve', required: true
      end
      def reserve
        @num_pages = job_queue_params[:num_pages].to_i
        @proc_id = JobQueue.generate_proc_id
        processing_id = JobStatus.processing.id

        JobQueue.unreserved.limit(@num_pages).update_all(proc_id: @proc_id, job_status_id: processing_id)

        @job_queues = JobQueue.where(proc_id: @proc_id, job_status_id: processing_id)
        respond_with @job_queues
      end

      private

      def job_queue_params
        params.require(:job_queue).permit(:num_pages)
      end

      def query_params
        params.permit(:job_status_id, :num_pages, :proc_id)
      end

    end
  end
end
