# Describes a results of a job run on a page
#
class PageResult < ActiveRecord::Base
  belongs_to :page
  belongs_to :batch_job, foreign_key: 'batch_id'

  validates :page, uniqueness: { scope: :batch_job }
  validates :page, presence: true
  validates :batch_job, presence: true

  def to_builder(version = 'v1')
    case version
    when 'v1'
      Jbuilder.new do |json|
        json.call(self, :id, :ocr_text_path, :ocr_xml_path, :ocr_completed)
        json.call(self, :corr_ocr_text_path, :corr_ocr_xml_path)
        json.call(self, :juxta_change_index, :alt_change_index)
        json.page page.to_builder
        json.batch_job batch_job.to_builder
      end
    end
  end

  def local_text_path
    File.join(Rails.application.secrets.emop_path_prefix, ocr_text_path)
  end

  def local_xml_path
    File.join(Rails.application.secrets.emop_path_prefix, ocr_xml_path)
  end

  def local_idhmc_text_path
    local_idhmc_path(local_text_path)
  end

  def local_idhmc_xml_path
    local_idhmc_path(local_xml_path)
  end

  private

  def local_idhmc_path(path)
    dir = File.dirname(path)
    ext = File.extname(path)
    name = File.basename(path, ext)
    new_name = "#{name}_IDHMC#{ext}"
    idhmc_path = File.join(Rails.application.secrets.emop_path_prefix, dir, new_name)
    idhmc_path
  end
end
