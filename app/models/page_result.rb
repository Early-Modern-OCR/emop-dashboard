# Describes a results of a job run on a page
#
class PageResult < ActiveRecord::Base
  belongs_to :page
  belongs_to :batch_job, foreign_key: 'batch_id'

  validates :page, uniqueness: { scope: :batch_job }

  def to_builder(version = 'v1')
    case version
    when 'v1'
      Jbuilder.new do |json|
        json.(self, :id, :ocr_text_path, :ocr_xml_path, :ocr_completed)
        json.(self, :juxta_change_index, :alt_change_index, :noisiness_idx)
        json.page       page.to_builder
        json.batch_job  batch_job.to_builder
      end
    end
  end
end