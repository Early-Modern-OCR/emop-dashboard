class JobStatus < ActiveRecord::Base
  establish_connection("emop_#{Rails.env}".to_sym)
  self.table_name = :job_status
  self.primary_key = :id
  has_many :job_queues, foreign_key: 'job_status'

  validates :name, uniqueness: true

  def self.processing
    find_by_name('Processing')
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
