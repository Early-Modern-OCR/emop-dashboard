
class JobType < ActiveRecord::Base
   establish_connection(:emop)
   self.table_name = :job_type
   self.primary_key = :id
   has_many :batch_jobs, foreign_key: 'job_type'
end