class DashboardDatatable
  delegate :params, :link_to, to: :view

  attr_reader :view

  def initialize(view, q)
    @view = view
    @q = q
    @columns = [
      nil,nil,nil,nil,'wks_work_id', 'wks_book_id',
      'wks_gt_number', nil, 'wks_title','wks_author', nil,
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
      #ocr_job_type = JobType.find_by(name: 'OCR')
      #if ocr_job_type.present?
      #  batch_job = work.batch_jobs.where(job_type_id: ocr_job_type.id).first
      #else
        batch_job = work.batch_jobs.first
      #end
      [
        @view.work_checkbox(work, batch_job),
        @view.work_status(work, batch_job),
        @view.work_detail_link(work, batch_job),
        work.collection.present? ? work.collection.name : '',
        work.id,
        work.wks_book_id,
        work.wks_gt_number,
        work.language.present? ? work.language.name : '',
        work.wks_title,
        work.wks_author,
        work.print_font.present? ? work.print_font.name : '',
        @view.ocr_date(work),
        @view.ocr_engine(work, batch_job),
        @view.ocr_batch(work, batch_job),
        @view.accuracy_links(work, 'juxta_accuracy'),
        @view.accuracy_links(work, 'retas_accuracy')
      ]
    end
  end

  def works
    @works ||= fetch_works
  end

  def fetch_works
    search = Work.ransack(params[:q])
    works = search.result.order("#{sort_column} #{sort_direction}")
    works = works.page(page).per(per_page)
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
    if (search_col_idx == 11 || search_col_idx > 13) && params[:ocr] == "ocr_sched"
      search_col_idx = 4
    # don't allow sort on any OCR data when NONE filter is on
    elsif (search_col_idx > 10) && params[:ocr] == "ocr_none"
      search_col_idx = 4
    end

    @columns[search_col_idx] || 'wks_work_id'
  end

  def sort_direction
    params[:sSortDir_0] == 'desc' ? 'desc' : 'asc'
  end

  def page
    params[:iDisplayStart].to_i / per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 25
  end
end
