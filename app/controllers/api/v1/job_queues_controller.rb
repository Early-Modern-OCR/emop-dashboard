#class API::V1::JobQueueController < ApplicationController
#  def index
#    @job_queue = JobQueue.all
#    respond_to do |format|
#      format.json { render json: @job_queue }
#    end
#  end
#end
module Api
  module V1
    class JobQueuesController < V1::BaseController
      before_filter :find_batch_job

      api :GET, "/batch_jobs/:batch_job_id/job_queues", "List Job Queues"

      def index
        @job_queues = @batch_job.job_queues.all
        render json: @job_queues
      end

      api :GET, '/batch_jobs/:batch_job_id/job_queues/:id', 'Show a Job Queue'

      def show
        @job_queue = @batch_job.job_queues.find(params[:id])
        render json: @job_queue
      end

      private

      def find_batch_job
        @batch_job = BatchJob.find_by_id(params[:batch_job_id])
      end
    end
  end
end
