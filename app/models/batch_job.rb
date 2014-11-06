# Describes an eMOP batch job
#
class BatchJob < ActiveRecord::Base
  establish_connection("emop_#{Rails.env}".to_sym)
  self.table_name = :batch_job
  self.primary_key = :id
  belongs_to :font, foreign_key: 'font_id'
  belongs_to :ocr_engine, foreign_key: 'ocr_engine_id'
  belongs_to :job_type, foreign_key: 'job_type'
  has_many :job_queues, foreign_key: 'batch_id'

  validates :name, presence: true

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
