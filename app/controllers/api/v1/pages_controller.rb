module Api
  module V1
    class PagesController < V1::BaseController
      layout 'api/v1/layouts/index_without_count', only: :index

      api :GET, '/pages', 'List pages'
      param_group :pagination, V1::BaseController
      def index
        super
      end

      api :GET, '/pages/:id', 'Show a page'
      param :id, Integer, desc: 'Page ID', required: true
      def show
        super
      end

      api :PUT, '/pages/:id', 'Update a page'
      param :page, Hash, required: true do
        param :pg_ref_number, Integer
        param :pg_ground_truth_file, String
        param :pg_work_id, Integer
        param :pg_gale_ocr_file, String
        param :pg_image_path, String
      end
      def update
        super
      end

      private

      def page_params
        params.require(:page).permit(:pg_ref_number, :pg_ground_truth_file, :pg_work_id,
                                     :pg_gale_ocr_file, :pg_image_path)
      end

      def query_params
        # Modify values if passed key values to allow special queries
        case params[:pg_image_path]
        when /nil|null|NULL/
          params[:pg_image_path] = nil
        end

        params.permit(:pg_image_path)
      end
    end
  end
end
