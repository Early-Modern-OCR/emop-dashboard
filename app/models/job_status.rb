class JobStatus < ActiveRecord::Base
  has_many :job_queues, foreign_key: :job_status_id

  validates :name, uniqueness: true

  def self.not_started
    find_by_name('Not Started')
  end

  def self.processing
    find_by_name('Processing')
  end

  def self.pending_postprocess
    find_by_name('Pending Postprocess')
  end

  def self.done
    find_by_name('Done')
  end

  def self.failed
    find_by_name('Failed')
  end

  def self.ingest_failed
    find_by_name('Ingest Failed')
  end

  def to_builder(version = 'v1')
    case version
    when 'v1'
      Jbuilder.new do |json|
        json.(self, :id, :name)
      end
    end
  end
end
