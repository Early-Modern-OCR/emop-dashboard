# Describes a page from an eMOP work.
#
class Page < ActiveRecord::Base
  self.primary_key = :pg_page_id
  has_many :job_queues
  belongs_to :work, foreign_key: :pg_work_id
  has_many :page_results
  has_many :postproc_pages
  has_many :postprocesses, through: :postproc_pages

  validates :pg_ref_number, presence: true
  validates :pg_image_path, presence: true
  validates :work, presence: true

  validates :pg_ref_number, uniqueness: { scope: :work }
  validates :pg_image_path, uniqueness: true

  def page_result_by_batch_id(batch_id)
    self.page_results.select { |pr| pr.batch_id == batch_id.to_i }.first
  end

  def postproc_page_by_batch_id(batch_id)
    self.postproc_pages.select { |pp| pp.batch_job_id == batch_id.to_i }.first
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
    when 'v2'
      Jbuilder.new do |json|
        json.call(self, :id, :pg_ref_number)
        json.call(self, :pg_ground_truth_file, :pg_gale_ocr_file, :pg_image_path)
        json.call(self, :work)
      end
    end
  end

  #TODO: Remove once schema is sane
  def id
    read_attribute(:pg_page_id)
  end
end
