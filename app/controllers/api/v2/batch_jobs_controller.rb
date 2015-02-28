module Api
  module V2
    class BatchJobsController < V2::BaseController
      api :GET, '/batch_jobs', 'List batch jobs'
      param_group :pagination, V2::BaseController
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
        param :completed, Array, desc: 'Array of Job Queue IDs that completed', required: true, allow_nil: true
        param :failed, Array, desc: 'Array of Job Queues that failed', required: true, allow_nil: true do
          param :id, Integer, required: true
          param :results, String, required: false, allow_nil: true
        end
      end
      param :page_results, Array, desc: 'Page results', required: false, allow_nil: true do
        param :page_id, Integer, required: true
        param :batch_id, Integer, required: true
        param :ocr_text_path, String, required: true
        param :ocr_xml_path, String, required: true
        param :corr_ocr_text_path, String, required: false, allow_nil: true
        param :corr_ocr_xml_path, String, required: false, allow_nil: true
        param :juxta_change_index, Float, allow_nil:  true
        param :alt_change_index, Float, allow_nil:  true
      end
      param :postproc_results, Array, desc: 'Post process results', required: false, allow_nil: true do
        param :page_id, Integer, required: true
        param :batch_job_id, Integer, required: true
        param :pp_noisemsr, Float, allow_nil: true
        param :pp_ecorr, Float, allow_nil: true
        param :pp_pg_quality, Float, allow_nil: true
        param :pp_juxta, Float, allow_nil: true
        param :pp_retas, Float, allow_nil: true
        param :pp_health, String, allow_nil: true
        param :noisiness_idx, Float, allow_nil: true
        param :multicol, String, allow_nil: true
        param :skew_idx, String, allow_nil: true
      end
      def upload_results
        job_queues = params[:job_queues]
        page_results = params[:page_results] ||= []
        postproc_results = params[:postproc_results] ||= []
        @pg_imports = 0
        @pp_imports = 0

        unless job_queues[:completed].blank?
          @done_job_queues = JobQueue.where(id: job_queues[:completed])
          @done_job_queues.update_all(job_status_id: JobStatus.done.id)
        end

        unless job_queues[:failed].blank?
          job_queues[:failed].each do |failed|
            @failed_job_queue = JobQueue.find(failed[:id])
            @failed_job_queue.update(job_status_id: JobStatus.failed.id, results: failed[:results])
          end
        end

        pg_results = []
        page_results.each do |page_result|
          conditions = { page_id: page_result[:page_id], batch_id: page_result[:batch_id] }
          @page_result = PageResult.where(conditions).first_or_initialize
          # Merge ocr_completed into results
          page_result = page_result.merge(ocr_completed: Time.now)
          if @page_result.new_record?
            @page_result = PageResult.new(page_result_params(page_result))
            pg_results << @page_result
          else
            @page_result.update(page_result_params(page_result))
          end
        end

        @pg_imports = PageResult.import(pg_results)

        pp_results = []
        postproc_results.each do |postproc_result|
          conditions = { page_id: postproc_result[:page_id], batch_job_id: postproc_result[:batch_job_id] }
          @postproc_page = PostprocPage.where(conditions).first_or_initialize
          if @postproc_page.new_record?
            pp_results << PostprocPage.new(postproc_page_params(postproc_result))
          else
            @postproc_page.update_attributes(postproc_page_params(postproc_result))
          end
        end

        @pp_imports = PostprocPage.import(pp_results)
      end

      private

      def query_params
        params.permit()
      end

      def page_result_params(page_result)
        page_result.permit(:page_id, :batch_id, :ocr_text_path, :ocr_xml_path,
                           :corr_ocr_text_path, :corr_ocr_xml_path, :juxta_change_index,
                           :alt_change_index, :ocr_completed)
      end

      def postproc_page_params(postproc_page)
        postproc_page.permit(:page_id, :batch_job_id, :pp_noisemsr, :pp_ecorr,
                             :pp_pg_quality, :pp_juxta, :pp_retas, :pp_health,
                             :noisiness_idx, :multicol, :skew_idx)
      end
    end
  end
end
