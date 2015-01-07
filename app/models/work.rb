# Describes an eMOP work.
#
class Work < ActiveRecord::Base
  self.primary_key = :wks_work_id
  has_many :pages, foreign_key: :pg_work_id
  has_many :job_queues
  has_many :work_ocr_results
  belongs_to :print_font, foreign_key: :wks_primary_print_font

  # NOTES: for ECCO, non-null TCP means GT is available
  #        for EEBO, non-null MARC means GT is available
  scope :with_gt, -> { where('wks_tcp_number IS NOT NULL OR wks_marc_record IS NOT NULL') }
  scope :is_ecco, -> { where.not(wks_ecco_number: nil) }
  scope :is_eebo, -> { where(wks_ecco_number: nil) }
  scope :by_batch_job, ->(batch_job_id = nil) { joins(:job_queues).where(job_queues: {batch_id: batch_job_id}) }
  scope :ocr_done, -> { joins(:job_queues).where(job_queues: { job_status_id: JobStatus.done.id }) }
  scope :ocr_sched, -> {
    job_status_ids = []
    job_status_ids << JobStatus.not_started.id
    job_status_ids << JobStatus.processing.id
    joins(:job_queues).where(job_queues: { job_status_id: job_status_ids })
  }
  scope :ocr_ingest, -> { joins(:job_queues).where(job_queues: { job_status_id: JobStatus.done.id }) }
  scope :ocr_ingest_error, -> { joins(:job_queues).where(job_queues: { job_status_id: JobStatus.ingest_failed.id }) }
  scope :ocr_none, -> { includes(:job_queues).where(job_queues: { id: nil }) }
  scope :ocr_error, -> { joins(:job_queues).where(job_queues: { job_status_id: JobStatus.failed.id }) }

  def isECCO?
    if self.wks_ecco_number.present?
      return true
    else
      return false
    end
  end

  def to_builder(version = 'v1')
    case version
    when 'v1'
      Jbuilder.new do |json|
        json.id id
        json.wks_tcp_number wks_tcp_number
        json.wks_estc_number wks_estc_number
        json.wks_tcp_bibno wks_tcp_bibno
        json.wks_marc_record wks_marc_record
        json.wks_eebo_citation_id wks_eebo_citation_id
        json.wks_eebo_directory wks_eebo_directory
        json.wks_ecco_number wks_ecco_number
        json.wks_book_id wks_book_id
        json.wks_author wks_author
        json.wks_publisher wks_publisher
        json.wks_word_count wks_word_count
        json.wks_title wks_title
        json.wks_eebo_image_id wks_eebo_image_id
        json.wks_eebo_url wks_eebo_url
        json.wks_pub_date wks_pub_date
        json.wks_ecco_uncorrected_gale_ocr_path wks_ecco_uncorrected_gale_ocr_path
        json.wks_ecco_corrected_xml_path wks_ecco_corrected_xml_path
        json.wks_ecco_corrected_text_path wks_ecco_corrected_text_path
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
