# Describes an eMOP batch job
#
class BatchJob < ActiveRecord::Base
  belongs_to :font
  belongs_to :ocr_engine
  belongs_to :job_type
  belongs_to :language_model
  belongs_to :glyph_substitution_model
  has_many :job_queues, foreign_key: 'batch_id', dependent: :delete_all
  has_many :page_results, foreign_key: 'batch_id', dependent: :delete_all
  has_many :postproc_pages, dependent: :delete_all
  has_many :work_ocr_results, foreign_key: 'batch_id'
  has_many :font_training_results

  # self referencial 
  belongs_to :font_training_result_batch_job, class: BatchJob
  has_many :font_training_result_batch_jobs, foreign_key: :font_training_result_batch_job_id

  validates :name, presence: true
  validates :ocr_engine, presence: true
  validates :job_type, presence: true

  after_initialize :set_defaults

  scope :font_training, -> { includes(:job_type).where(job_types: { name: 'Font Training' }) }

  def self.default_ocr_engine
    OcrEngine.find_by_name('Tesseract')
  end

  def self.default_job_type
    JobType.find_by_name('OCR')
  end

  def set_defaults
    self.ocr_engine ||= BatchJob.default_ocr_engine
    self.job_type   ||= BatchJob.default_job_type
  end

  def to_builder(version = 'v1')
    case version
    when 'v1'
      Jbuilder.new do |json|
        json.(self, :id, :name, :parameters, :notes)
        json.job_type    job_type.to_builder
        json.ocr_engine  ocr_engine.to_builder
        json.font        font.to_builder
      end
    when 'v2'
      Jbuilder.new do |json|
        json.(self, :id, :name, :parameters, :notes)
        json.(self, :job_type, :ocr_engine, :font, :language_model, :glyph_substitution_model)
      end
    end
  end
end
