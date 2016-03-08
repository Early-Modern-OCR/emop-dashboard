class LanguageModel < ActiveRecord::Base
  belongs_to :language
  has_many :batch_jobs

  validates :name, uniqueness: true, presence: true
  validates :language, presence: true
  validates :path, uniqueness: true

  def file
    path
  end

  def file=(val)
    if Settings.language_model_path
      self.path = File.join(Settings.language_model_path, val.original_filename)
      File.open(self.path, 'wb') { |f| f.write(val.read) }
    end
  end

  def to_builder(version = 'v2')
    case version
    when 'v2'
      Jbuilder.new do |json|
        json.id             id
        json.name           name
        json.language_id    language_id
        json.path           path
      end
    end
  end

end
