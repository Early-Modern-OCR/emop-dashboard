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
    page_results.average(:juxta_change_index)
  end

  def retas_accuracy
    page_results.average(:alt_change_index)
  end

  def ocr_result
    page_results.group(:pg_work_id, :batch_id).first
  end

  def ocr_result_batch_job
    return nil unless ocr_result.present?
    ocr_result.batch_job
  end

  def self.filter_by_params(works, params)
    if params['sSearch'].present?
      works = works.where("wks_title LIKE :search OR wks_author LIKE :search OR wks_printer LIKE :search", search: "%#{params['sSearch']}%")
    end
    if params['gt'].present?
      case params['gt']
      when 'with_gt'
        works = works.with_gt
      when 'without_gt'
        works = works.without_gt
      end
    end
    if params['batch'].present?
      works = works.by_batch_job(params['batch'])
    end
    if params['font'].present?
      works = works.where(wks_primary_print_font: params['font'])
    end
    if params['collection'].present?
      works = works.where(collection_id: params['collection'])
    end
    if params['from'].present?
      works = works.joins(:work_ocr_results).where("work_ocr_results.ocr_completed > ?", params['from'])
    end
    if params['to'].present?
      works = works.joins(:work_ocr_results).where("work_ocr_results.ocr_completed < ?", params['to'])
    end

    if params['ocr'].present?
      case params['ocr']
      when 'ocr_done'
        works = works.ocr_done
      when 'ocr_sched'
        works = works.ocr_sched
      when 'ocr_ingest'
        works = works.ocr_ingest
      when 'ocr_ingest_error'
        works = works.ocr_ingest_error
      when 'ocr_none'
        works = works.ocr_none
      when 'ocr_error'
        works = works.ocr_error
      end
    end

    works
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
end
