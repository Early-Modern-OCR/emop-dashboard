class JobType < ActiveRecord::Base
  has_many :batch_jobs

  validates :name, uniqueness: true

  def to_builder(version = 'v1')
    case version
    when 'v1'
      Jbuilder.new do |json|
        json.(self, :id, :name)
      end
    end
  end
end