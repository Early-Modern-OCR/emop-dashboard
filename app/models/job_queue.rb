# Describes the emop job queue
#
class JobQueue < ActiveRecord::Base
  belongs_to :batch_job, foreign_key: 'batch_id'
  belongs_to :page
  belongs_to :status, class_name: 'JobStatus', foreign_key: 'job_status_id'
  belongs_to :work

  validates :batch_job, presence: true
  validates :page, presence: true
  validates :status, presence: true

  after_initialize :set_defaults, if: :new_record?

  def set_defaults
    self.status ||= JobStatus.find_by_name('Not Started')
  end

  def self.generate_proc_id
    Time.now.strftime('%Y%m%d%H%M%S%L')
  end

  def self.unreserved
    @job_status = JobStatus.find_by_name('Not Started')
    where(proc_id: nil, job_status_id: @job_status.id)
  end

  def to_builder(version = 'v1')
    case version
    when 'v1'
      Jbuilder.new do |json|
        json.(self, :id, :tries, :results)
        json.status     status.to_builder
        json.batch_job  batch_job.to_builder
        json.page       page.to_builder
        json.work       work.to_builder
        json.proc_id    proc_id
      end
    end
  end

end
