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

end
