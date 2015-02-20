class DashboardDatatable
  delegate :params, :link_to, to: :view

  attr_reader :view

  def initialize(view)
    @view = view
    @columns = [
      nil,nil,nil,nil,'wks_work_id',
      'wks_tcp_number','wks_title','wks_author','print_fonts.pf_name',
      'work_ocr_results.ocr_completed','work_ocr_results.ocr_engine_id',
      'work_ocr_results.batch_id','work_ocr_results.juxta_accuracy',
      'work_ocr_results.retas_accuracy'
    ]
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Work.count,
      iTotalDisplayRecords: works.total_count,
      data: data
    }
  end

  private

  def data
    works.map do |work|
      {
        work_select: @view.work_checkbox(work),
        status: @view.work_status(work),
        detail_link: @view.work_detail_link(work),
        data_set: @view.data_set(work),
        id: work.id,
        tcp_number: work.wks_tcp_number,
        title: work.wks_title,
        author: work.wks_author,
        font: work.print_font.present? ? work.print_font.name : '',
        ocr_date: @view.ocr_date(work),
        ocr_engine: @view.ocr_engine(work),
        ocr_batch: @view.ocr_batch(work),
        juxta_url: @view.accuracy_links(work, 'juxta_accuracy'),
        retas_url: @view.accuracy_links(work, 'retas_accuracy')
      }
    end
  end

  def works
    @works ||= fetch_works
  end

  def fetch_works
    works = Work.includes(:work_ocr_results, :print_font)
    works = works.order("#{sort_column} #{sort_direction}")
    works = works.page(page).per(per_page)
    works = Work.filter_by_params(works, params)
    works
  end

  def sort_column
    if params[:iSortCol_0].present?
      search_col_idx = params[:iSortCol_0].to_i
    else
      search_col_idx = 4
    end

    # enforce some rules on what columns can be sorted based on OCR filter setting:
    # don't allow sort on results or date when error filter is on; no data exists for these
    if (search_col_idx == 9 || search_col_idx > 11) && params[:ocr] == "ocr_sched"
      search_col_idx = 4
    # don't allow sort on any OCR data when NONE filter is on
    elsif (search_col_idx > 8) && params[:ocr] == "ocr_none"
      search_col_idx = 4
    end

    @columns[search_col_idx]
  end

  def sort_direction
    params[:sSortDir_0] == 'desc' ? 'desc' : 'asc'
  end

  def page
    params[:iDisplayStart]
  end

  def per_page
    params[:iDisplayLength]
  end
end
