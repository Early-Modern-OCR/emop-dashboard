module Api
  module V1
    class BatchJobsController < V1::BaseController

      api :GET, '/batch_jobs', 'List batch jobs'
      param_group :pagination, V1::BaseController
      def index
        super
      end

      api :GET, '/batch_jobs/:id', 'Show a batch job'
      param :id, Integer, desc: 'Batch job ID', required: true
      def show
        super
      end

      api :GET, '/batch_jobs/count', 'Count of batch jobs'
      def count
        @count = BatchJob.count(:all)
        respond_with @count
      end

      api :PUT, '/batch_jobs/upload_results', 'Upload batch job results'
      param :job_queues, Hash, required: true do
        param :completed, Array, desc: 'Array of Job Queue IDs that completed', required: true, allow_nil:  true
        param :failed, Array, desc: 'Array of Job Queue IDs that failed', required: true, allow_nil:  true
      end
      param :page_results, Array, desc: 'Page results', required: false do
        param :page_id, Integer, required: true
        param :batch_id, Integer, required: true
        param :ocr_text_path, String, required: true
        param :ocr_xml_path, String, required: true
        param :juxta_change_index, Float, allow_nil:  true
        param :alt_change_index, Float, allow_nil:  true
      end
      param :postproc_results, Array, desc: 'Post process results', required: false do
        param :page_id, Integer, required: true
        param :batch_job_id, Integer, required: true
        param :pp_ecorr, Float, allow_nil:  true
        param :pp_stats, Float, allow_nil:  true
        param :pp_juxta, Float, allow_nil:  true
        param :pp_retas, Float, allow_nil:  true
        param :pp_health, Float, allow_nil:  true
        param :noisiness_idx, Float, allow_nil:  true
        param :multicol, String, allow_nil: true
        param :skew_idx, String, allow_nil: true
      end
      def upload_results
        job_queues = params[:job_queues]
        page_results = params[:page_results]
        postproc_results = params[:postproc_results]
        @pg_imports = 0
        @pp_imports = 0

        unless job_queues[:completed].blank?
          @done_job_queues = JobQueue.where("id IN (?)", job_queues[:completed])
          @done_job_queues.update_all(job_status_id: JobStatus.done.id)
        end

        unless job_queues[:failed].blank?
          @failed_job_queues = JobQueue.where("id IN (?)", job_queues[:failed])
          @failed_job_queues.update_all(job_status_id: JobStatus.failed.id)
        end

        unless page_results.blank?
          pg_results = []
          page_results.each do |page_result|
            @page_result = PageResult.new(page_result.permit(:page_id, :batch_id, :ocr_text_path, :ocr_xml_path, :juxta_change_index, :alt_change_index))
            @page_result.ocr_completed = Time.now
            pg_results << @page_result
          end

          @pg_imports = PageResult.import(pg_results)
        end

        unless postproc_results.blank?
          pp_results = []
          postproc_results.each do |postproc_result|
            pp_results << PostprocPage.new(postproc_result.permit(:page_id, :batch_job_id, :pp_ecorr, :pp_stats, :pp_juxta, :pp_retas, :pp_health, :noisiness_idx, :multicol, :skew_idx))
          end

          @pp_imports = PostprocPage.import(pp_results)
        end
      end

      private

      def query_params
        params.permit()
      end

    end
  end
end
