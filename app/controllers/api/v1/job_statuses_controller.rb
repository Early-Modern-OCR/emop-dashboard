#class API::V1::JobStatusController < ApplicationController
#  def index
#    @job_status = JobStatus.all
#    respond_to do |format|
#      format.json { render json: @job_status }
#    end
#  end
#end
module Api
  module V1
    class JobStatusesController < V1::BaseController
      before_filter :find_job_status, except: [:index]

      api :GET, "/job_statuses", "List job statuses"

      def index
        @job_statuses = JobStatus.all
        render json: @job_statuses
      end

      api :GET, '/job_statuses/:id', 'Show a job status'

      def show
        render json: @job_status
      end

      api :GET, '/job_statuses/:id/job_queues(/:limit)', "List a job status' job queues" 

      def job_queues
        params[:limit] ||= nil

        @job_queues = @job_status.job_queues.limit(params[:limit])
        render json: @job_queues
      end

      private

      def find_job_status
        @job_status = JobStatus.find(params[:id])
      end
    end
  end
end
