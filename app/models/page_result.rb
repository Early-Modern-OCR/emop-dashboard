# Describes a results of a job run on a page
#
class PageResult < ActiveRecord::Base
  belongs_to :page
  belongs_to :batch_job, foreign_key: 'batch_id'

  validates :page, uniqueness: { scope: :batch_job }

  # get the type of ocr engine used to generate this result
  #
  # TODO: Appears unused
  def get_ocr_engine
    batch_job = BatchJob.find( self.batch_id )
    ocr_id = batch_job.ocr_engine_id
    return :gale if ocr_id == 1   
    return :tesseract if ocr_id == 2
    return :gamera if ocr_id == 3
    return :ocropus if ocr_id == 4
    return :none
  end

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