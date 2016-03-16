class GlyphSubstitutionModel < ActiveRecord::Base

  validates :name, uniqueness: true, presence: true
  validates :path, uniqueness: true

  def file
    path
  end

  def file=(val)
    if Settings.gsm_path
      self.path = File.join(Settings.gsm_path, val.original_filename)
      File.open(self.path, 'wb') { |f| f.write(val.read) }
    end
  end

  def to_builder(version = 'v2')
    case version
    when 'v2'
      Jbuilder.new do |json|
        json.id             id
        json.name           name
        json.path           path
      end
    end
  end

end
