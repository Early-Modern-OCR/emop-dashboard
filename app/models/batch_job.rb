# Describes an eMOP batch job
#
class BatchJob < ActiveRecord::Base
  belongs_to :font
  belongs_to :ocr_engine
  belongs_to :job_type
  has_many :job_queues, foreign_key: 'batch_id'
  has_many :postproc_pages
  has_many :postprocesses, through: :postproc_pages
  has_many :work_ocr_results
  has_many :ocr_results, through: :work_ocr_results

  validates :name, presence: true

  after_initialize :set_defaults

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
    end
  end
end
