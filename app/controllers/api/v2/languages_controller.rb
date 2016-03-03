module Api
  module V2
    class LanguagesController < V2::BaseController

      api :GET, '/languages', 'List languages'
      param :name, String, desc: 'Language name'
      def index
        super
      end

      api :GET, '/languages/:id', 'Show language'
      param :id, Integer, desc: 'Work Collection ID', required: true
      def show
        super
      end

      api :POST, '/languages', 'Create a language'
      param :language, Hash, required: true do
        param :name, String, required: true
      end
      def create
        super
      end

      private

      def query_params
        params.permit(:id, :name)
      end

      def language_params
        params.require(:language).permit(:name)
      end
    end
  end
end
