module Api
  module V2
    class PagesController < V2::BaseController
      layout 'api/v2/layouts/index_without_count', only: :index

      api :GET, '/pages', 'List pages'
      param_group :pagination, V2::BaseController
      def index
        super
      end

      api :GET, '/pages/:id', 'Show a page'
      param :id, Integer, desc: 'Page ID', required: true
      def show
        super
      end

      api :POST, '/pages', 'Create a page'
      param :page, Hash, required: true do
        param :pg_ref_number, Integer, required: true
        param :pg_ground_truth_file, String
        param :pg_work_id, Integer, required: true
        param :pg_gale_ocr_file, String
        param :pg_image_path, String, required: true
      end
      def create
        super
      end

      api :POST, '/pages/create_bulk', 'Create multiple pages'
      param :pages, Array, 'Pages', required: true do
        param :pg_ref_number, Integer, required: true
        param :pg_ground_truth_file, String
        param :pg_work_id, Integer, required: true
        param :pg_gale_ocr_file, String
        param :pg_image_path, String, required: true
      end
      def create_bulk
        pages = params[:pages]
        new_pages = []
        pages.each do |p|
          @page = Page.new(page_bulk_params(p))
          new_pages << @page
        end

        count_before = Page.count
        @pages = Page.import(new_pages)
        count_after = Page.count
        @imported = count_after - count_before
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

      api :DELETE, '/pages/:id', 'Delete a page'
      param :id, Integer, desc: 'Page ID', required: true
      def destroy
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

      def page_bulk_params(page)
        page.permit(:pg_ref_number, :pg_ground_truth_file, :pg_work_id,
                    :pg_gale_ocr_file, :pg_image_path)
      end
    end
  end
end
