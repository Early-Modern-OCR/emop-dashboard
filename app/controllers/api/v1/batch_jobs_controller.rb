#class API::V1::BatchJobController < ApplicationController
#  def index
#    @job_queue = BatchJob.all
#    respond_to do |format|
#      format.json { render json: @job_queue }
#    end
#  end
#end
module Api
  module V1
    class BatchJobsController < V1::BaseController

      api :GET, "/batch_jobs", "List batch jobs"

      def index
        @batch_jobs = BatchJob.all
        render json: @batch_jobs
      end

      api :GET, '/batch_jobs/:id', 'Show a batch job'

      def show
        @batch_job = BatchJob.find(params[:id])
        render json: @batch_job
      end

      api :GET, '/batch_jobs/first/:n', 'Show first :n batch jobs'

      def first
        @batch_jobs = BatchJob.limit(params[:n])
        render json: @batch_jobs
      end

    end
  end
end
