module Api
  module V2
    class FontTrainingResultsController < V2::BaseController

      api :GET, '/font_training_results', 'List font training results'
      param :work_id, Integer, desc: 'Work ID'
      param :batch_job_id, Integer, desc: 'BatchJob ID'
      def index
        super
      end

      api :GET, '/font_training_results/:id', 'Show a font training result'
      param :id, Integer, desc: 'Font training result ID', required: true
      def show
        super
      end

      private

      def query_params
        params.permit(:id, :work_id, :batch_job_id)
      end
    end
  end
end
