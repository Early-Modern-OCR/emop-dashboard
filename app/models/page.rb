# Describes a page from an eMOP work.
#
class Page < ActiveRecord::Base
  self.primary_key = :pg_page_id
  has_many :job_queues
  belongs_to :work, foreign_key: :pg_work_id
  has_many :postproc_pages
  has_many :postprocesses, through: :postproc_pages

  # TODO: Appears unused
  def get_latest_result( ocr_engine )
    pages = PageResult.where(:page_id => self.id).order("ocr_completed desc")
    pages.each do |page|
       res_ocr = page.get_ocr_engine
       if res_ocr == ocr_engine
          return page
       end
    end
    return  nil
  end

  def to_builder(version = 'v1')
    case version
    when 'v1'
      Jbuilder.new do |json|
        json.id                   id
        json.pg_ref_number        pg_ref_number
        json.pg_ground_truth_file pg_ground_truth_file
        json.work                 work.to_builder
        json.pg_gale_ocr_file     pg_gale_ocr_file
        json.pg_image_path        pg_image_path
      end
    end
  end

  #TODO: Remove once schema is sane
  def id
    read_attribute(:pg_page_id)
  end
end
