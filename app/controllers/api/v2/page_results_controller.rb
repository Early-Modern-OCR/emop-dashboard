module Api
  module V2
    class PageResultsController < V2::BaseController
      layout 'api/v2/layouts/index_without_count', only: :index

      api :GET, '/page_results', 'List page results'
      param_group :pagination, V2::BaseController
      param :page_id, Integer, desc: 'Page ID', required: false
      param :batch_id, Integer, desc: 'BatchJob ID', required: false
      param :works, Hash, required: false do
        param :wks_work_id, Integer, 'Work ID'
      end
      def index
        @page_results = PageResult.page(paginate_params[:page_num]).per(paginate_params[:per_page])
        if query_params.key?(:works)
          @page_results = @page_results.joins(:work)
        end
        @page_results = @page_results.where(query_params)

        respond_with @page_results
      end

      api :GET, '/page_results/:id', 'Show a page result'
      param :id, Integer, desc: 'Page result ID', required: true
      def show
        super
      end

      private

      def query_params
        params.permit(:page_id, :batch_id, :works => [ :wks_work_id ])
      end
    end
  end
end
