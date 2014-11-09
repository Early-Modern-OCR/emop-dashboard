
# Describes a results of a job run on a page
#
class PostprocPage < ActiveRecord::Base
  belongs_to :page
  belongs_to :batch_job
end
