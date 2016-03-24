module Api
  module V2
    class PrintFontsController < V2::BaseController

      api :GET, '/print_fonts', 'List print fonts'
      param :pf_name, String, desc: 'Print font name'
      def index
        super
      end

      api :GET, '/print_fonts/:id', 'Show print font'
      param :id, Integer, desc: 'Print font ID', required: true
      def show
        super
      end

      api :POST, '/print_fonts', 'Create a print font'
      param :print_font, Hash, required: true do
        param :pf_name, String, required: true
      end
      def create
        super
      end

      private

      def query_params
        params.permit(:id, :name)
      end

      def print_font_params
        params.require(:print_font).permit(:pf_name)
      end
    end
  end
end
