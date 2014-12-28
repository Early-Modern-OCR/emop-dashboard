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

  scope :pending, -> { joins(:status).where(job_statuses: {name: 'Not Started'}) }
  scope :running, -> { joins(:status).where(job_statuses: {name: 'Processing'}) }
  scope :postprocess, -> { joins(:status).where(job_statuses: {name: 'Pending Postprocess'}) }
  scope :done, -> { joins(:status).where(job_statuses: {name: 'Done'}) }
  scope :failed, -> { joins(:status).where(job_statuses: {name: 'Failed'}) }
  scope :ingest_failed, -> { joins(:status).where(job_statuses: {name: 'Ingest Failed'}) }

  def set_defaults
    self.status ||= JobStatus.find_by_name('Not Started')
  end

  def self.generate_proc_id
    Time.now.strftime('%Y%m%d%H%M%S%L')
  end

  def results=(value)
    if value.present?
      new_value = value.truncate(255)
    else
      new_value = value
    end
    write_attribute(:results, new_value)
  end

  def mark_not_started!
    update(proc_id: nil, status: JobStatus.find_by_name('Not Started'))
  end

  def mark_failed!
    update(results: "Marked failed using dashboard.", status: JobStatus.find_by_name("Failed"))
  end

  def self.unreserved
    @job_status = JobStatus.find_by_name('Not Started')
    where(proc_id: nil, job_status_id: @job_status.id)
  end

  def self.status_summary
    summary = {}
    summary[:pending] = self.pending.count
    summary[:running] = self.running.count
    summary[:postprocess] = self.postprocess.count
    summary[:done] = self.done.count
    summary[:failed] = self.failed.count
    summary[:ingestfailed] = self.ingest_failed.count

    summary[:total] =  summary[:ingestfailed] +
                       summary[:failed] +
                       summary[:done] +
                       summary[:postprocess] +
                       summary[:running] +
                       summary[:pending]

    return summary
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
