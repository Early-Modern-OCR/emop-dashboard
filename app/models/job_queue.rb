# Describes the emop job queue
#
class JobQueue < ActiveRecord::Base
  establish_connection("emop_#{Rails.env}".to_sym)
  self.table_name = :job_queue
  self.primary_key = :id
  belongs_to :batch_job, foreign_key: 'batch_id'
  belongs_to :page, foreign_key: 'page_id'
  belongs_to :status, class_name: 'JobStatus', foreign_key: 'job_status'
  belongs_to :work, foreign_key: 'work_id'

  def to_builder(version = 'v1')
    case version
    when 'v1'
      Jbuilder.new do |json|
        json.(self, :id, :tries, :results)
        json.batch_job  batch_job.to_builder
        json.page       page.to_builder
        json.work       work.to_builder
        json.proc_id    proc_id
      end
    end
  end
end
