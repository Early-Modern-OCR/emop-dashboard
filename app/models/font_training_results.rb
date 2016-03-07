class FontTrainingResult < ActiveRecord::Base
  belongs_to :work
  belongs_to :batch_job

  validates :path, presence: true
  validates :work, presence: true
  validates :batch_job, presence: true
  validates :path, uniqueness: { scope: [:work, :batch_job] }

  def to_builder(version = 'v2')
    case version
    when 'v2'
      Jbuilder.new do |json|
        json.id             id
        json.work_id        work_id
        json.batch_job_id   batch_job_id
        json.path           path
      end
    end
  end

end
