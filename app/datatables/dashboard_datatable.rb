class DashboardDatatable
  delegate :params, :link_to, to: :view

  attr_reader :view

  def initialize(view)
    @view = view
    @columns = [
      nil,nil,nil,nil,'wks_work_id',
      'wks_gt_number','wks_title','wks_author', nil,
      nil,nil,nil,nil,nil
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
      batch_job = work.batch_jobs.first
      {
        work_select: @view.work_checkbox(work, batch_job),
        status: @view.work_status(work, batch_job),
        detail_link: @view.work_detail_link(work, batch_job),
        collection: work.collection.present? ? work.collection.name : '',
        id: work.id,
        gt_number: work.wks_gt_number,
        title: work.wks_title,
        author: work.wks_author,
        font: work.print_font.present? ? work.print_font.name : '',
        ocr_date: @view.ocr_date(work),
        ocr_engine: @view.ocr_engine(work, batch_job),
        ocr_batch: @view.ocr_batch(work, batch_job),
        juxta_url: @view.accuracy_links(work, 'juxta_accuracy'),
        retas_url: @view.accuracy_links(work, 'retas_accuracy')
      }
    end
  end

  def works
    @works ||= fetch_works
  end

  def fetch_works
    works = Work.order("#{sort_column} #{sort_direction}")
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

    @columns[search_col_idx] || 'wks_work_id'
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
