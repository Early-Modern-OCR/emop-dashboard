class JobStatus < ActiveRecord::Base
  establish_connection(:emop)
  self.table_name = :job_status
  self.primary_key = :id
  has_many :job_queues, foreign_key: 'job_status'
end
