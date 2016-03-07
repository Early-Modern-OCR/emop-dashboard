module Api
  module V2
    class WorksCollectionsController < V2::BaseController

      api :GET, '/works_collections', 'List works collections'
      param :name, String, desc: 'Work Collection name'
      def index
        super
      end

      api :GET, '/works_collections/:id', 'Show a works collection'
      param :id, Integer, desc: 'Work Collection ID', required: true
      def show
        super
      end

      api :POST, '/works_collections', 'Create a works collection'
      param :works_collection, Hash, required: true do
        param :name, String, required: true
      end
      def create
        super
      end

      private

      def query_params
        params.permit(:id, :name)
      end

      def works_collection_params
        params.require(:works_collection).permit(:name)
      end
    end
  end
end
