module Api
  module V2
    class JobQueuesController < V2::BaseController
      layout 'api/v2/layouts/index_without_count', only: :index

      api :GET, '/job_queues', 'List job queues'
      param_group :pagination, V2::BaseController
      param :job_status_id, Integer, desc: 'Job status ID'
      param :batch_id, Integer, desc: 'Batch job ID'
      param :work_id, Integer, desc: 'Work ID'
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
      param :batch_id, Integer, desc: 'Batch job ID'
      param :work_id, Integer, desc: 'Work ID'
      param :works, :boolean, desc: 'Count pending works instead of pages'
      def count
        filter = query_params.except(:works)
        if query_params.key?(:works) && query_params[:works].to_bool
          @count = JobQueue.where(filter).group(:work_id).pluck(:work_id).count
        else
          @count = JobQueue.where(filter).count
        end
        respond_with @count
      end

      api :PUT, '/job_queues/reserve', 'Reserve job queues'
      param :job_queue, Hash, required: true do
        param :num_pages, Integer, desc: 'Number of pages to reserve, if works is true then this sets number of works', required: true
        param :batch_id, Integer, desc: 'Batch job ID'
        param :work_id, Integer, desc: 'Work ID'
        param :works, :boolean, desc: 'Reserve entire works'
      end
      def reserve
        @num_pages = job_queue_params[:num_pages].to_i
        @proc_id = JobQueue.generate_proc_id
        processing_id = JobStatus.processing.id
        filter = job_queue_params.except(:num_pages, :works)

        if job_queue_params.key?(:works) && job_queue_params[:works].to_bool
          work_ids = JobQueue.unreserved.where(filter).group(:work_id).limit(@num_pages).pluck(:work_id)
          JobQueue.unreserved.where(filter).where(work_id: work_ids).update_all(proc_id: @proc_id, job_status_id: processing_id)
        else
          JobQueue.unreserved.where(filter).limit(@num_pages)
            .update_all(proc_id: @proc_id, job_status_id: processing_id)
        end

        @job_queues = JobQueue.where(filter).where(proc_id: @proc_id, job_status_id: processing_id)
        respond_with @job_queues
      end

      api :PUT, '/job_queues/set_job_id', 'Set JobQueue job ID'
      param :job_queue, Hash, required: true do
        param :proc_id, String, desc: 'ProcID', required: true
        param :job_id, String, desc: 'Cluster JobID', required: true
      end
      def set_job_id
        @job_queues = JobQueue.where(proc_id: set_job_id_params[:proc_id])
        if @job_queues.update_all(job_id: set_job_id_params[:job_id])
          render json: nil, status: :ok
        else
          render json: nil, status: :unprocessable_entity
        end
      end

      private

      def job_queue_params
        params.require(:job_queue).permit(:num_pages, :batch_id, :work_id, :works)
      end

      def set_job_id_params
        params.require(:job_queue).permit(:proc_id, :job_id)
      end

      def query_params
        params.permit(:job_status_id, :num_pages, :proc_id, :batch_id, :work_id, :works)
      end

    end
  end
end
