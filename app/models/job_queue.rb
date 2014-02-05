# Describes the emop job queue
#
class JobQueue < ActiveRecord::Base
  establish_connection(:emop)
  self.table_name = :job_queue
  self.primary_key = :id
  belongs_to :batch_job, foreign_key: 'batch_id'
  belongs_to :page, foreign_key: 'page_id'
  belongs_to :status, class_name: 'JobStatus', foreign_key: 'job_status'
end
