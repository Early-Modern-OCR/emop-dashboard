module Api
  module V1
    class PostprocPagesController < V1::BaseController
      api :GET, '/postproc_pages', 'List postproc page results'
      param_group :pagination, V1::BaseController
      param :page_id, Integer, desc: 'Page ID', required: false
      param :batch_job_id, Integer, desc: 'BatchJob ID', required: false
      def index
        super
      end

      api :GET, '/postproc_pages/:id', 'Show a postproc page result'
      param :id, Integer, desc: 'Postproc page result ID', required: true
      def show
        super
      end

      private

      def query_params
        params.permit(:page_id, :batch_job_id)
      end
    end
  end
end
