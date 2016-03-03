# Describes an eMOP work.
#
class Work < ActiveRecord::Base
  self.primary_key = :wks_work_id
  has_many :pages, foreign_key: :pg_work_id, dependent: :destroy
  has_many :job_queues
  has_many :work_ocr_results
  belongs_to :print_font, foreign_key: :wks_primary_print_font
  has_many :batch_jobs, -> { uniq }, through: :job_queues
  has_many :page_results, -> { uniq }, through: :pages
  belongs_to :collection, class_name: 'WorksCollection', foreign_key: :collection_id

  validates :wks_title, uniqueness: true

  # NOTES: for ECCO, non-null TCP means GT is available
  #        for EEBO, non-null MARC means GT is available
  scope :with_gt, -> { where('wks_gt_number IS NOT NULL OR wks_marc_record IS NOT NULL') }
  scope :without_gt, -> { where(wks_gt_number: nil, wks_marc_record: nil) }
  scope :is_ecco, -> { joins(:collection).where(works_collections: { name: 'ECCO'}) }
  scope :is_eebo, -> { joins(:collection).where(works_collections: { name: 'EEBO'}) }
  scope :by_batch_job, ->(batch_job_id = nil) { includes(:job_queues).where(job_queues: {batch_id: batch_job_id}) }
  scope :ocr_done, -> { includes(:job_queues).where(job_queues: { job_status_id: JobStatus.done.id }) }
  scope :ocr_sched, -> {
    job_status_ids = []
    job_status_ids << JobStatus.not_started.id
    job_status_ids << JobStatus.processing.id
    includes(:job_queues).where(job_queues: { job_status_id: job_status_ids })
  }
  scope :ocr_ingest, -> { includes(:job_queues).where(job_queues: { job_status_id: JobStatus.done.id }) }
  scope :ocr_ingest_error, -> { includes(:job_queues).where(job_queues: { job_status_id: JobStatus.ingest_failed.id }) }
  scope :ocr_none, -> { includes(:job_queues).where(job_queues: { id: nil }) }
  scope :ocr_error, -> { includes(:job_queues).where(job_queues: { job_status_id: JobStatus.failed.id }) }

  def isECCO?
    if self.collection.present? && self.collection.name == 'ECCO'
      return true
    else
      return false
    end
  end

  def juxta_accuracy
    val = page_results.average(:juxta_change_index)
    if val.present?
      val.round(3)
    else
      val
    end
  end

  def retas_accuracy
    val = page_results.average(:alt_change_index)
    if val.present?
      val.round(3)
    else
      val
    end
  end

  def ocr_result
    page_results.group(:pg_work_id, :batch_id).first
  end

  def ocr_result_batch_job
    return nil unless ocr_result.present?
    ocr_result.batch_job
  end

  def ocr_completed_date
    if self.ocr_result.present? && self.ocr_result.ocr_completed.present?
      self.ocr_result.ocr_completed.to_datetime.strftime("%m/%d/%Y %H:%M")
    else
      nil
    end
  end

  def self.ground_truth(gt)
    case gt
    when 'with_gt'
      with_gt
    when 'without_gt'
      without_gt
    end
  end

  def self.ocr_filter(o)
    case o
    when 'ocr_done'
      ocr_done
    when 'ocr_sched'
      ocr_sched
    when 'ocr_ingest'
      ocr_ingest
    when 'ocr_ingest_error'
      ocr_ingest_error
    when 'ocr_none'
      ocr_none
    when 'ocr_error'
      ocr_error
    end
  end

  def self.ocr_completed_date_from(date)
    joins(:work_ocr_results).where("work_ocr_results.ocr_completed > ?", date)
  end

  def self.ocr_completed_date_to(date)
    joins(:work_ocr_results).where("work_ocr_results.ocr_completed < ?", date)
  end

  def to_builder(version = 'v1')
    case version
    when 'v1'
      Jbuilder.new do |json|
        json.id id
        # Leave wks_tcp_number in place for external apps
        json.wks_tcp_number wks_gt_number
        json.wks_estc_number wks_estc_number
        # Leave wks_bib_name in place for external apps
        json.wks_bib_name wks_coll_name
        json.wks_tcp_bibno wks_tcp_bibno
        json.wks_marc_record wks_marc_record
        json.wks_eebo_citation_id wks_eebo_citation_id
        # Leave wks_eebo_directory in place for external apps
        json.wks_eebo_directory wks_doc_directory
        json.wks_ecco_number wks_ecco_number
        json.wks_book_id wks_book_id
        json.wks_author wks_author
        # Leave wks_publisher in place for external apps
        json.wks_publisher wks_printer
        json.wks_word_count wks_word_count
        json.wks_title wks_title
        json.wks_eebo_image_id wks_eebo_image_id
        json.wks_eebo_url wks_eebo_url
        json.wks_pub_date wks_pub_date
        json.wks_ecco_uncorrected_gale_ocr_path wks_ecco_uncorrected_gale_ocr_path
        # Leave wks_ecco_corrected_xml_path in place for external apps
        json.wks_ecco_corrected_xml_path wks_corrected_xml_path
        # Leave wks_ecco_corrected_text_path in place for external apps
        json.wks_ecco_corrected_text_path wks_corrected_text_path
        json.wks_ecco_directory wks_ecco_directory
        json.wks_ecco_gale_ocr_xml_path wks_ecco_gale_ocr_xml_path
        json.wks_organizational_unit wks_organizational_unit
        json.wks_primary_print_font wks_primary_print_font
        json.wks_last_trawled wks_last_trawled
      end
    when 'v2'
      Jbuilder.new do |json|
        json.id id
        json.collection collection
        json.wks_gt_number wks_gt_number
        json.wks_estc_number wks_estc_number
        json.wks_coll_name wks_coll_name
        json.wks_tcp_bibno wks_tcp_bibno
        json.wks_marc_record wks_marc_record
        json.wks_eebo_citation_id wks_eebo_citation_id
        json.wks_doc_directory wks_doc_directory
        json.wks_ecco_number wks_ecco_number
        json.wks_book_id wks_book_id
        json.wks_author wks_author
        json.wks_printer wks_printer
        json.wks_word_count wks_word_count
        json.wks_title wks_title
        json.wks_eebo_image_id wks_eebo_image_id
        json.wks_eebo_url wks_eebo_url
        json.wks_pub_date wks_pub_date
        json.wks_ecco_uncorrected_gale_ocr_path wks_ecco_uncorrected_gale_ocr_path
        json.wks_corrected_xml_path wks_corrected_xml_path
        json.wks_corrected_text_path wks_corrected_text_path
        json.wks_ecco_directory wks_ecco_directory
        json.wks_ecco_gale_ocr_xml_path wks_ecco_gale_ocr_xml_path
        json.wks_organizational_unit wks_organizational_unit
        json.wks_primary_print_font wks_primary_print_font
        json.wks_last_trawled wks_last_trawled
      end
    end
  end

  #TODO: Remove once schema is sane
  def id
    read_attribute(:wks_work_id)
  end

  def self.to_csv(options = {})
    column_names = [
      'Work ID',
      'Collection',
      'Title',
      'Author',
      'Font',
      'OCR Date',
      'OCR Engine',
      'OCR Batch',
      'Juxta',
      'RETAS'
    ]
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |work|
        line = []
        line.push(work.id)
        if work.collection.present?
          line.push(work.collection.name)
        else
          line.push('')
        end
        line.push(work.wks_title)
        line.push(work.wks_author)
        if work.print_font.present?
          line.push(work.print_font.name)
        else
          line.push('')
        end
        line.push(work.ocr_completed_date)
        if work.ocr_result_batch_job.present?
          line.push(work.ocr_result_batch_job.ocr_engine.name)
          line.push("#{work.ocr_result_batch_job.id}: #{work.ocr_result_batch_job.name}")
        else
          line.push('')
          line.push('')
        end
        if work.juxta_accuracy.present?
          line.push(work.juxta_accuracy)
        else
          line.push('N/A')
        end
        if work.retas_accuracy.present?
          line.push(work.retas_accuracy)
        else
          line.push('N/A')
        end
        csv << line
      end
    end
  end

  private

  def self.ransackable_scopes(auth_object = nil)
    %i(ground_truth ocr_filter by_batch_job ocr_completed_date_from ocr_completed_date_to)
  end

  def self.ransackable_attributes(auth_object = nil)
    (column_names - ["collection_id", "wks_last_trawled"]) + _ransackers.keys
  end

end
