# Describes OCR accuracy for a batch of eMOP work.
#
class WorkOcrResult < ActiveRecord::Base
  self.primary_key = :work_id
  belongs_to :work
  belongs_to :batch_job, foreign_key: 'batch_id'

  before_destroy :raise_readonly

  # Attempt to make this MySQL view read-only
  def readonly?
    true
  end

  # Attempt to make this MySQL view read-only
  def raise_readonly
    raise ActiveRecord::ReadOnlyRecord
  end
end
