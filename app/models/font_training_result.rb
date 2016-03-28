class FontTrainingResult < ActiveRecord::Base
  belongs_to :work
  belongs_to :batch_job

  validates :work, presence: true
  validates :batch_job, presence: true
  validates :font_path, uniqueness: { scope: [:work, :batch_job] }
  validates :language_model_path, uniqueness: { scope: [:work, :batch_job] }
  validates :glyph_substitution_model_path, uniqueness: { scope: [:work, :batch_job] }

  def to_builder(version = 'v2')
    case version
    when 'v2'
      Jbuilder.new do |json|
        json.id                             id
        json.work_id                        work_id
        json.batch_job_id                   batch_job_id
        json.font_path                      font_path
        json.language_model_path            language_model_path
        json.glyph_substitution_model_path  glyph_substitution_model_path
      end
    end
  end

end
