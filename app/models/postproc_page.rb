
# Describes a results of a job run on a page
#
class PostprocPage < ActiveRecord::Base
  belongs_to :page
  belongs_to :batch_job

  validates :page, uniqueness: { scope: :batch_job }
  validates :page, presence: true
  validates :batch_job, presence: true

  def to_builder(version = 'v1')
    case version
    when 'v1'
      Jbuilder.new do |json|
        json.(self, :pp_noisemsr, :pp_ecorr, :pp_juxta, :pp_retas, :pp_health, :pp_stats)
        json.(self, :noisiness_idx, :multicol, :skew_idx)
        json.page       page.to_builder
        json.batch_job  batch_job.to_builder
      end
    end
  end
end
