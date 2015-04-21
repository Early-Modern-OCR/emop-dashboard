module Api
  module V2
    class PostprocPagesController < V2::BaseController
      layout 'api/v2/layouts/index_without_count', only: :index

      api :GET, '/postproc_pages', 'List postproc page results'
      param_group :pagination, V2::BaseController
      param :page_details, :boolean, desc: 'Show page association attributes', required: false
      param :page_id, Integer, desc: 'Page ID', required: false
      param :batch_job_id, Integer, desc: 'BatchJob ID', required: false
      param :works, Hash, required: false do
        param :wks_work_id, Integer, 'Work ID'
      end
      def index
        if params.key?(:page_details)
          @page_details = params[:page_details].to_bool
        else
          @page_details = false
        end
        @postproc_pages = PostprocPage.page(paginate_params[:page_num]).per(paginate_params[:per_page])
        if query_params.key?(:works) && query_params[:works].present?
          @postproc_pages = @postproc_pages.joins(:work)
        end
        @postproc_pages = @postproc_pages.where(query_params)
      end

      api :GET, '/postproc_pages/:id', 'Show a postproc page result'
      param :id, Integer, desc: 'Postproc page result ID', required: true
      def show
        super
      end

      private

      def query_params
        params.permit(:page_id, :batch_job_id, :works => [ :wks_work_id ])
      end
    end
  end
end
