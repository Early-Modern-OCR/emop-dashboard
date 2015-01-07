module Api
  module V1
    class PageResultsController < V1::BaseController
      api :GET, '/page_results', 'List page results'
      param_group :pagination, V1::BaseController
      param :page_id, Integer, desc: 'Page ID', required: false
      param :batch_id, Integer, desc: 'BatchJob ID', required: false
      def index
        super
      end

      api :GET, '/page_results/:id', 'Show a page result'
      param :id, Integer, desc: 'Page result ID', required: true
      def show
        super
      end

      private

      def query_params
        params.permit(:page_id, :batch_id)
      end
    end
  end
end
