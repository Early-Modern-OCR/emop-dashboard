# Describes an eMOP batch job
#
class BatchJob < ActiveRecord::Base
  establish_connection(:emop)
  self.table_name = :batch_job
  self.primary_key = :id
  belongs_to :font, foreign_key: 'font_id'
  belongs_to :ocr_engine, foreign_key: 'ocr_engine_id'
  belongs_to :job_type, foreign_key: 'job_type'
  has_many :job_queues, foreign_key: 'batch_id'
end
